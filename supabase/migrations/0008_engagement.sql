-- =====================================================================
-- Flamengos — 0008: enganche
--   1. Flamengos del día: 3 perfiles escogidos (más etiquetas en común),
--      con aviso a las 9:00 (hora de RD) para quien está soltero y activo.
--   2. Pregunta del día para parejas: cada uno ve la respuesta del otro
--      solo después de responder.
--   3. Racha de pareja: días seguidos en que los dos se escribieron o los
--      dos respondieron la pregunta del día.
--   4. Personas nuevas cerca: aviso a las 19:00 (como mucho cada 3 días)
--      si hay perfiles nuevos compatibles que comparten etiquetas.
--
-- Requiere 0007. Ejecutar completo en: Supabase → SQL Editor → Run.
-- =====================================================================

alter type public.notification_type add value if not exists 'daily_picks';
alter type public.notification_type add value if not exists 'new_nearby';
alter type public.notification_type add value if not exists 'daily_answer';

-- Datos extra de la notificación (p. ej. {"count": 4}).
alter table public.notifications add column if not exists data jsonb;

-- El "día" de la app es el de República Dominicana.
create function public.local_today() returns date
  language sql stable as $$
  select (now() at time zone 'America/Santo_Domingo')::date
$$;

-- ---------------------------------------------------------------------
-- Descubrir para cualquier usuario (lo usan las funciones de abajo).
-- discover() queda igual para la app, ahora llamando a esta.
-- ---------------------------------------------------------------------
create function public._discover_for(p_user uuid, p_limit int default 30) returns setof jsonb
  language sql stable security definer set search_path = public as $$
  with me as (
    select p.*,
           coalesce(p.search_lat, p.lat) as c_lat,
           coalesce(p.search_lng, p.lng) as c_lng
    from profiles p
    where p.id = p_user
  ),
  candidates as (
    select p,
           case when me.c_lat is not null and p.lat is not null
                then distance_km(me.c_lat, me.c_lng, p.lat, p.lng) end as dist,
           cardinality(array(select unnest(p.tags) intersect select unnest(me.tags))) as shared,
           coalesce(p.boost_until > now(), false) as boosted
    from profiles p, me
    where p.id <> me.id
      and me.current_match_id is null
      and p.current_match_id is null
      and p.banned_at is null
      and not (p.incognito and is_premium(p.id))
      and p.gender = any (me.interested_in)
      and me.gender = any (p.interested_in)
      and extract(year from age(p.birthdate)) between me.age_min and me.age_max
      and me.must_tags <@ p.tags
      and not is_blocked_between(me.id, p.id)
      and (select count(distinct reporter_id) from reports r
           where r.reported_id = p.id and r.status = 'open') < 3
      and not exists (
        select 1 from requests r
        where ((r.sender_id = me.id and r.receiver_id = p.id)
            or (r.sender_id = p.id and r.receiver_id = me.id))
          and (r.status = 'pending'
            or (r.status = 'declined' and r.resolved_at > now() - interval '30 days'))
      )
      and not exists (
        select 1 from passes x
        where x.user_id = me.id and x.target_id = p.id
          and x.created_at > now() - interval '7 days'
      )
  )
  select to_jsonb(c.p)
         - 'current_match_id' - 'search_lat' - 'search_lng' - 'search_label'
         - 'age_min' - 'age_max' - 'max_distance_km'
         - 'premium_until' - 'incognito' - 'must_tags' - 'boost_until' - 'banned_at'
         || jsonb_build_object('distance_km', round(c.dist::numeric, 1),
                               'shared_tags', c.shared)
  from candidates c, me
  where me.max_distance_km is null
     or me.c_lat is null
     or (c.dist is not null and c.dist <= me.max_distance_km)
  order by c.boosted desc, c.shared desc, c.dist nulls last, random()
  limit least(p_limit, 100);
$$;

create or replace function public.discover(p_limit int default 30) returns setof jsonb
  language sql stable security definer set search_path = public as $$
  select * from _discover_for(auth.uid(), p_limit);
$$;

-- ---------------------------------------------------------------------
-- 1. Flamengos del día
-- ---------------------------------------------------------------------
create table public.daily_picks (
  user_id   uuid not null references public.profiles (id) on delete cascade,
  day       date not null,
  target_id uuid not null references public.profiles (id) on delete cascade,
  primary key (user_id, day, target_id)
);
alter table public.daily_picks enable row level security;
revoke all on public.daily_picks from anon, authenticated;

-- Se escogen la primera vez que se piden en el día y no cambian hasta
-- mañana. Solo devuelve los que siguen disponibles.
create function public.my_daily_picks() returns setof jsonb
  language plpgsql security definer set search_path = public as $$
declare
  v_me  uuid := auth.uid();
  v_day date := local_today();
begin
  if v_me is null then raise exception 'not_authenticated'; end if;
  if not exists (select 1 from daily_picks where user_id = v_me and day = v_day) then
    insert into daily_picks (user_id, day, target_id)
    select v_me, v_day, (j->>'id')::uuid
    from (select j from _discover_for(v_me, 40) j
          order by (j->>'shared_tags')::int desc, random()
          limit 3) s
    on conflict do nothing;
  end if;
  return query
  select j from _discover_for(v_me, 100) j
  where (j->>'id')::uuid in (select target_id from daily_picks
                             where user_id = v_me and day = v_day);
end $$;

-- Solteros que usaron la app en los últimos 14 días.
create function public._active_singles() returns setof uuid
  language sql stable security definer set search_path = public as $$
  select p.id from profiles p
  where p.current_match_id is null and p.banned_at is null
    and exists (select 1 from usage_daily u
                where u.user_id = p.id and u.day > current_date - 14);
$$;

-- plpgsql (no sql): así no se valida al crearla, porque 'daily_picks' se
-- agrega al enum en esta misma transacción.
create function public.notify_daily_picks() returns void
  language plpgsql security definer set search_path = public as $
begin
  insert into notifications (user_id, type)
  select s.uid, 'daily_picks' from _active_singles() as s(uid);
end $;

-- ---------------------------------------------------------------------
-- 2 y 3. Pregunta del día y racha
-- ---------------------------------------------------------------------
-- Debe coincidir con la cantidad de preguntas en la app (dailyQuestion0…).
create function public.cfg_daily_questions() returns int
  language sql immutable as $$ select 30 $$;

create table public.couple_answers (
  match_id   uuid not null references public.matches (id) on delete cascade,
  user_id    uuid not null references public.profiles (id) on delete cascade,
  day        date not null,
  answer     text not null check (char_length(answer) between 1 and 300),
  created_at timestamptz not null default now(),
  primary key (match_id, user_id, day)
);
alter table public.couple_answers enable row level security;
revoke all on public.couple_answers from anon, authenticated;

create function public._couple_streak(p_match uuid) returns int
  language sql stable security definer set search_path = public as $$
  with active_days as (
    -- Días en que los dos escribieron…
    select (created_at at time zone 'America/Santo_Domingo')::date as d
    from messages where match_id = p_match
    group by 1 having count(distinct sender_id) = 2
    union
    -- …o los dos respondieron la pregunta del día.
    select day from couple_answers where match_id = p_match
    group by day having count(*) = 2
  ),
  islands as (
    select d, d - (row_number() over (order by d))::int as grp from active_days
  ),
  last_run as (
    select grp, max(d) as last_day, count(*) as len
    from islands group by grp order by max(d) desc limit 1
  )
  -- Sigue viva si el último día activo fue hoy o ayer.
  select coalesce((select len::int from last_run
                   where last_day >= local_today() - 1), 0);
$$;

-- Todo lo del día de la pareja en una llamada.
create function public.couple_daily() returns jsonb
  language plpgsql stable security definer set search_path = public as $$
declare
  v_me    uuid := auth.uid();
  v_day   date := local_today();
  v_match uuid;
  v_other uuid;
  v_mine  text;
  v_their text;
begin
  select m.id, case when m.user_a = v_me then m.user_b else m.user_a end
  into v_match, v_other
  from matches m join profiles p on p.current_match_id = m.id
  where p.id = v_me;
  if v_match is null then raise exception 'not_paired'; end if;

  select answer into v_mine from couple_answers
  where match_id = v_match and user_id = v_me and day = v_day;
  select answer into v_their from couple_answers
  where match_id = v_match and user_id = v_other and day = v_day;

  return jsonb_build_object(
    'question', (v_day - date '2026-01-01') % cfg_daily_questions(),
    'my_answer', v_mine,
    'partner_answered', v_their is not null,
    -- La del otro solo se ve después de responder.
    'partner_answer', case when v_mine is not null then v_their end,
    'streak', _couple_streak(v_match),
    'today_active', exists (
      select 1 from messages where match_id = v_match
        and (created_at at time zone 'America/Santo_Domingo')::date = v_day
      group by match_id having count(distinct sender_id) = 2)
      or (v_mine is not null and v_their is not null));
end $$;

create function public.answer_daily_question(p_answer text) returns void
  language plpgsql security definer set search_path = public as $$
declare
  v_me    uuid := auth.uid();
  v_match uuid;
  v_other uuid;
  v_new   boolean;
begin
  select m.id, case when m.user_a = v_me then m.user_b else m.user_a end
  into v_match, v_other
  from matches m join profiles p on p.current_match_id = m.id
  where p.id = v_me and m.status <> 'dissolved';
  if v_match is null then raise exception 'not_paired'; end if;

  p_answer := trim(p_answer);
  if char_length(p_answer) not between 1 and 300 then raise exception 'message_invalid'; end if;

  v_new := not exists (select 1 from couple_answers
                       where match_id = v_match and user_id = v_me and day = local_today());
  insert into couple_answers (match_id, user_id, day, answer)
  values (v_match, v_me, local_today(), p_answer)
  on conflict (match_id, user_id, day) do update set answer = excluded.answer;

  if v_new then
    insert into notifications (user_id, type, actor_id) values (v_other, 'daily_answer', v_me);
  end if;
end $$;

-- ---------------------------------------------------------------------
-- 4. Personas nuevas cerca
-- ---------------------------------------------------------------------
create function public.notify_new_nearby() returns void
  language plpgsql security definer set search_path = public as $$
declare
  v_user  uuid;
  v_count int;
begin
  for v_user in
    select s.uid from _active_singles() as s(uid)
    where not exists (select 1 from notifications n
                      where n.user_id = s.uid and n.type = 'new_nearby'
                        and n.created_at > now() - interval '3 days')
  loop
    select count(*) into v_count
    from _discover_for(v_user, 100) j
    where (j->>'created_at')::timestamptz > now() - interval '3 days'
      and ((j->>'shared_tags')::int > 0
           or (select cardinality(tags) from profiles where id = v_user) = 0);
    if v_count > 0 then
      insert into notifications (user_id, type, data)
      values (v_user, 'new_nearby', jsonb_build_object('count', v_count));
    end if;
  end loop;
end $$;

-- ---------------------------------------------------------------------
-- Horarios (UTC): 13:00 = 9:00 en RD; 23:00 = 19:00 en RD.
-- ---------------------------------------------------------------------
do $$
begin
  perform cron.schedule('flamengos-daily-picks', '0 13 * * *', 'select public.notify_daily_picks()');
  perform cron.schedule('flamengos-new-nearby', '0 23 * * *', 'select public.notify_new_nearby()');
exception when others then
  raise notice 'pg_cron no disponible (%): los avisos diarios no se enviarán.', sqlerrm;
end $$;

-- ---------------------------------------------------------------------
-- Permisos
-- ---------------------------------------------------------------------
revoke execute on function public._discover_for(uuid, int)      from public, anon, authenticated;
revoke execute on function public._active_singles()             from public, anon, authenticated;
revoke execute on function public.notify_daily_picks()          from public, anon, authenticated;
revoke execute on function public.notify_new_nearby()           from public, anon, authenticated;
revoke execute on function public._couple_streak(uuid)          from public, anon, authenticated;
revoke execute on function public.my_daily_picks()              from public, anon;
revoke execute on function public.couple_daily()                from public, anon;
revoke execute on function public.answer_daily_question(text)   from public, anon;
