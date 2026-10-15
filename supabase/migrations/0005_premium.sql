-- =====================================================================
-- Flamengos — 0005: Premium
--   * Las primeras 100 cuentas son "fundadoras": premium para siempre.
--   * Las demás reciben 3 días de prueba al crear el perfil.
--   * Premium: 5 solicitudes activas (en vez de 3), modo incógnito y
--     confirmaciones de lectura. "Escribiendo…" y "en línea" usan Realtime
--     Presence y la app los muestra solo a cuentas premium.
--
-- Ejecutar completo en: Supabase → SQL Editor → New query → Run.
-- =====================================================================

alter table public.profiles
  -- Solo los cambian las funciones de este archivo (no hay grant).
  add column founder       boolean not null default false,
  add column premium_until timestamptz,
  -- Lo elige el usuario; solo tiene efecto mientras sea premium.
  add column incognito     boolean not null default false;

grant update (incognito) on public.profiles to authenticated;

create function public.cfg_founder_slots() returns int
  language sql immutable as $$ select 100 $$;
create function public.cfg_premium_trial() returns interval
  language sql immutable as $$ select interval '3 days' $$;

create function public.is_premium(p_user uuid) returns boolean
  language sql stable security definer set search_path = public as $$
  select coalesce(
    (select founder or coalesce(premium_until > now(), false)
     from profiles where id = p_user),
    false);
$$;

create function public.max_active_requests(p_user uuid) returns int
  language sql stable security definer set search_path = public as $$
  select case when is_premium(p_user) then 5 else cfg_max_active_requests() end;
$$;

-- Fundador o prueba al crear el perfil. El candado evita que dos registros
-- simultáneos ocupen el mismo cupo.
create function public.assign_premium() returns trigger
  language plpgsql security definer set search_path = public as $$
begin
  perform pg_advisory_xact_lock(hashtext('flamengos_founders'));
  new.founder := (select count(*) from profiles where founder) < cfg_founder_slots();
  new.premium_until := case when new.founder then null else now() + cfg_premium_trial() end;
  return new;
end $$;

create trigger profiles_assign_premium before insert on public.profiles
  for each row execute function public.assign_premium();

-- Cuentas existentes: las más antiguas son fundadoras.
update public.profiles set founder = true
where id in (select id from public.profiles order by created_at limit 100);

-- ---------------------------------------------------------------------
-- Solicitudes: el límite depende de premium
-- ---------------------------------------------------------------------
create or replace function public.send_request(p_target uuid) returns jsonb
  language plpgsql security definer set search_path = public as $$
declare
  v_me       uuid := auth.uid();
  v_me_match uuid;
  v_tg_match uuid;
  v_reverse  uuid;
  v_req      uuid;
begin
  if v_me is null then raise exception 'not_authenticated'; end if;
  if p_target = v_me then raise exception 'cannot_request_self'; end if;

  perform housekeeping();
  perform _lock_pair(v_me, p_target);

  select current_match_id into v_me_match from profiles where id = v_me;
  if not found then raise exception 'profile_incomplete'; end if;
  if v_me_match is not null then raise exception 'already_paired'; end if;

  select current_match_id into v_tg_match from profiles where id = p_target;
  if not found then raise exception 'target_not_found'; end if;
  if v_tg_match is not null then raise exception 'target_paired'; end if;

  if is_blocked_between(v_me, p_target) then raise exception 'target_unavailable'; end if;

  select id into v_reverse from requests
  where sender_id = p_target and receiver_id = v_me and status = 'pending';
  if v_reverse is not null then
    return jsonb_build_object('result', 'matched',
                              'match_id', _create_match(v_reverse, v_me, p_target));
  end if;

  if exists (select 1 from requests
             where sender_id = v_me and receiver_id = p_target and status = 'pending') then
    raise exception 'already_requested';
  end if;

  if exists (select 1 from requests
             where status = 'declined' and resolved_at > now() - interval '30 days'
               and ((sender_id = v_me and receiver_id = p_target)
                 or (sender_id = p_target and receiver_id = v_me))) then
    raise exception 'target_unavailable';
  end if;

  if (select count(*) from requests where sender_id = v_me and status = 'pending')
     >= max_active_requests(v_me) then
    raise exception 'max_active_requests';
  end if;

  insert into requests (sender_id, receiver_id) values (v_me, p_target)
  returning id into v_req;
  delete from passes where user_id = v_me and target_id = p_target;

  return jsonb_build_object('result', 'sent', 'request_id', v_req);
end $$;

-- ---------------------------------------------------------------------
-- Descubrimiento: oculta a quien está en incógnito (y es premium)
-- ---------------------------------------------------------------------
create or replace function public.discover(p_limit int default 30) returns setof jsonb
  language sql stable security definer set search_path = public as $$
  with me as (
    select p.*,
           coalesce(p.search_lat, p.lat) as c_lat,
           coalesce(p.search_lng, p.lng) as c_lng
    from profiles p
    where p.id = auth.uid()
  ),
  candidates as (
    select p,
           case when me.c_lat is not null and p.lat is not null
                then distance_km(me.c_lat, me.c_lng, p.lat, p.lng) end as dist
    from profiles p, me
    where p.id <> me.id
      and me.current_match_id is null
      and p.current_match_id is null
      and not (p.incognito and is_premium(p.id))
      and p.gender = any (me.interested_in)
      and me.gender = any (p.interested_in)
      and extract(year from age(p.birthdate)) between me.age_min and me.age_max
      and not is_blocked_between(me.id, p.id)
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
         - 'premium_until' - 'incognito'
         || jsonb_build_object('distance_km', round(c.dist::numeric, 1))
  from candidates c, me
  where me.max_distance_km is null
     or me.c_lat is null
     or (c.dist is not null and c.dist <= me.max_distance_km)
  order by c.dist nulls last, random()
  limit least(p_limit, 100);
$$;

-- ---------------------------------------------------------------------
-- Confirmaciones de lectura: hasta dónde leyó cada quien el chat.
-- Cada uno ve su propia fila; la del otro solo si es premium.
-- ---------------------------------------------------------------------
create table public.chat_reads (
  match_id     uuid not null references public.matches (id) on delete cascade,
  user_id      uuid not null references public.profiles (id) on delete cascade,
  last_read_at timestamptz not null default now(),
  primary key (match_id, user_id)
);

alter table public.chat_reads enable row level security;
revoke insert, update, delete on public.chat_reads from anon, authenticated;

create policy "chat_reads: leer" on public.chat_reads
  for select to authenticated using (
    user_id = auth.uid()
    or (public.is_premium(auth.uid()) and public.is_open_match_member(match_id))
  );

create function public.mark_chat_read(p_match uuid) returns void
  language plpgsql security definer set search_path = public as $$
begin
  if not is_open_match_member(p_match) then raise exception 'not_paired'; end if;
  insert into chat_reads (match_id, user_id) values (p_match, auth.uid())
  on conflict (match_id, user_id) do update set last_read_at = now();
end $$;

revoke execute on function public.mark_chat_read(uuid)      from public, anon;
revoke execute on function public.is_premium(uuid)          from public, anon;
revoke execute on function public.max_active_requests(uuid) from public, anon;

alter publication supabase_realtime add table public.chat_reads;
