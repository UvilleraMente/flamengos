-- =====================================================================
-- Flamengos — 0007
--   1. Panel de administración: verificaciones, reportes, fotos y bloqueo
--      de cuentas. Solo para quienes estén en la tabla admins.
--   2. Moderación de fotos: cada foto nueva entra a una cola de revisión.
--      Con 3 reportes abiertos de personas distintas, el perfil se oculta
--      de Descubrir hasta que un admin lo revise.
--   3. Etiquetas (hasta 5) y "imprescindibles" (hasta 2) en la búsqueda.
--   4. Impulso: tras 3 rechazos en 7 días sin ninguna aceptación, el perfil
--      sale primero en Descubrir durante 24 h (invisible para los demás).
--   5. Estadísticas premium: tiempo en la app, conexiones, parejas,
--      cuánto duraron y por qué terminaron (encuesta al terminar).
--
-- Ejecutar completo en: Supabase → SQL Editor → New query → Run.
-- Después, hazte admin (cambia el correo por el de tu cuenta en la app):
--   insert into public.admins (user_id)
--   select id from auth.users where email = 'tu-correo@ejemplo.com';
-- =====================================================================

-- ---------------------------------------------------------------------
-- Nuevos tipos de notificación
-- ---------------------------------------------------------------------
alter type public.notification_type add value if not exists 'photo_rejected';
alter type public.notification_type add value if not exists 'boost_started';

-- ---------------------------------------------------------------------
-- 1. Admins
-- ---------------------------------------------------------------------
create table public.admins (
  user_id    uuid primary key references public.profiles (id) on delete cascade,
  created_at timestamptz not null default now()
);
alter table public.admins enable row level security;
revoke all on public.admins from anon, authenticated;

create function public.is_admin() returns boolean
  language sql stable security definer set search_path = public as $$
  select exists (select 1 from admins where user_id = auth.uid());
$$;

create function public._require_admin() returns void
  language plpgsql stable security definer set search_path = public as $$
begin
  if not is_admin() then raise exception 'not_admin'; end if;
end $$;

-- Los admins ven las selfies de verificación (bucket privado).
create policy "verifications: admins ven" on storage.objects
  for select to authenticated using (bucket_id = 'verifications' and public.is_admin());

alter table public.profiles add column banned_at timestamptz;

-- ---------------------------------------------------------------------
-- 2. Moderación de fotos
-- ---------------------------------------------------------------------
create table public.photo_reviews (
  path        text primary key,
  user_id     uuid not null references public.profiles (id) on delete cascade,
  status      text not null default 'pending'
              check (status in ('pending', 'approved', 'rejected')),
  created_at  timestamptz not null default now(),
  reviewed_at timestamptz
);
create index photo_reviews_pending on public.photo_reviews (created_at) where status = 'pending';
alter table public.photo_reviews enable row level security;
revoke all on public.photo_reviews from anon, authenticated;

create function public._queue_photos() returns trigger
  language plpgsql security definer set search_path = public as $$
begin
  insert into photo_reviews (path, user_id)
  select p, new.id from unnest(new.photos) as p
  where p not like 'http%'          -- cuentas de prueba con fotos externas
  on conflict (path) do nothing;
  return null;
end $$;

create trigger profiles_queue_photos
  after insert or update of photos on public.profiles
  for each row execute function public._queue_photos();

-- Fotos que ya existían: cuentan como aprobadas.
insert into public.photo_reviews (path, user_id, status, reviewed_at)
select p, id, 'approved', now() from public.profiles, unnest(photos) as p
where p not like 'http%'
on conflict (path) do nothing;

-- ---------------------------------------------------------------------
-- 3. Etiquetas
-- ---------------------------------------------------------------------
-- Debe coincidir con ProfileTag en la app.
create function public.cfg_tags() returns text[]
  language sql immutable as $$
  select array[
    'christian', 'catholic', 'spiritual',
    'worker', 'student', 'entrepreneur',
    'sports', 'gym', 'gamer', 'reader', 'traveler', 'foodie', 'music',
    'dance', 'pets', 'nature', 'beach', 'homebody', 'party',
    'family', 'wants_kids', 'no_smoking', 'no_drinking', 'serious'
  ]
$$;

alter table public.profiles
  add column tags      text[] not null default '{}'
    check (cardinality(tags) <= 5 and tags <@ public.cfg_tags()),
  add column must_tags text[] not null default '{}'
    check (cardinality(must_tags) <= 2 and must_tags <@ public.cfg_tags());

grant insert (tags, must_tags) on public.profiles to authenticated;
grant update (tags, must_tags) on public.profiles to authenticated;

-- ---------------------------------------------------------------------
-- 4. Impulso
-- ---------------------------------------------------------------------
alter table public.profiles add column boost_until timestamptz;

create function public._maybe_boost() returns trigger
  language plpgsql security definer set search_path = public as $$
declare
  v_boost timestamptz;
begin
  if old.status <> 'pending' or new.status not in ('declined', 'expired') then
    return null;
  end if;

  select boost_until into v_boost from profiles where id = new.sender_id;
  -- Como mucho un impulso cada 3 días.
  if v_boost is not null and v_boost > now() - interval '3 days' then return null; end if;

  if (select count(*) from requests
      where sender_id = new.sender_id and status in ('declined', 'expired')
        and resolved_at > now() - interval '7 days') >= 3
     and not exists (select 1 from requests
                     where sender_id = new.sender_id and status = 'accepted'
                       and resolved_at > now() - interval '7 days') then
    update profiles set boost_until = now() + interval '24 hours' where id = new.sender_id;
    insert into notifications (user_id, type) values (new.sender_id, 'boost_started');
  end if;
  return null;
end $$;

create trigger requests_maybe_boost
  after update of status on public.requests
  for each row execute function public._maybe_boost();

-- ---------------------------------------------------------------------
-- Descubrir: imprescindibles, etiquetas en común, impulso, ocultos
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

-- ---------------------------------------------------------------------
-- 5. Estadísticas premium
-- ---------------------------------------------------------------------
create table public.usage_daily (
  user_id uuid not null references public.profiles (id) on delete cascade,
  day     date not null default current_date,
  seconds int  not null default 0,
  primary key (user_id, day)
);
alter table public.usage_daily enable row level security;
revoke all on public.usage_daily from anon, authenticated;

-- La app lo llama cada minuto mientras está abierta.
create function public.track_usage(p_seconds int) returns void
  language sql security definer set search_path = public as $$
  insert into usage_daily (user_id, seconds)
  values (auth.uid(), least(greatest(p_seconds, 0), 120))
  on conflict (user_id, day) do update
  set seconds = usage_daily.seconds + excluded.seconds;
$$;

-- Encuesta al terminar una pareja (solo la ve quien la responde).
create table public.match_feedback (
  match_id   uuid not null references public.matches (id) on delete cascade,
  user_id    uuid not null references public.profiles (id) on delete cascade,
  reason     text not null check (reason in (
               'no_chemistry', 'different_goals', 'distance', 'communication',
               'met_someone', 'disrespect', 'other')),
  note       text check (char_length(note) <= 300),
  created_at timestamptz not null default now(),
  primary key (match_id, user_id)
);
alter table public.match_feedback enable row level security;
revoke all on public.match_feedback from anon, authenticated;

create function public.submit_match_feedback(p_match uuid, p_reason text, p_note text default null)
  returns void
  language plpgsql security definer set search_path = public as $$
begin
  if not exists (select 1 from matches where id = p_match and auth.uid() in (user_a, user_b)) then
    raise exception 'not_paired';
  end if;
  insert into match_feedback (match_id, user_id, reason, note)
  values (p_match, auth.uid(), p_reason, nullif(trim(p_note), ''))
  on conflict (match_id, user_id) do update
  set reason = excluded.reason, note = excluded.note, created_at = now();
end $$;

create function public.my_insights() returns jsonb
  language plpgsql stable security definer set search_path = public as $$
declare
  v_me uuid := auth.uid();
begin
  if not is_premium(v_me) then raise exception 'premium_required'; end if;
  return jsonb_build_object(
    'seconds_today', coalesce((select seconds from usage_daily
                               where user_id = v_me and day = current_date), 0),
    'seconds_7d',  coalesce((select sum(seconds) from usage_daily
                             where user_id = v_me and day > current_date - 7), 0),
    'seconds_30d', coalesce((select sum(seconds) from usage_daily
                             where user_id = v_me and day > current_date - 30), 0),
    'usage_14d', coalesce((
      select jsonb_agg(jsonb_build_object('day', d::date, 'seconds', coalesce(u.seconds, 0))
                       order by d)
      from generate_series(current_date - 13, current_date, interval '1 day') d
      left join usage_daily u on u.user_id = v_me and u.day = d::date), '[]'),
    'sent',     (select count(*) from requests where sender_id = v_me),
    'received', (select count(*) from requests where receiver_id = v_me),
    'sent_by_status', coalesce((
      select jsonb_object_agg(status, n) from (
        select status, count(*) n from requests where sender_id = v_me group by status) s), '{}'),
    'received_by_status', coalesce((
      select jsonb_object_agg(status, n) from (
        select status, count(*) n from requests where receiver_id = v_me group by status) s), '{}'),
    'couples', coalesce((
      select jsonb_agg(jsonb_build_object(
               'started', m.created_at,
               'ended', m.dissolved_at,
               'partner', p.display_name,
               'reason', f.reason)
             order by m.created_at desc)
      from matches m
      left join profiles p on p.id = case when m.user_a = v_me then m.user_b else m.user_a end
      left join match_feedback f on f.match_id = m.id and f.user_id = v_me
      where v_me in (m.user_a, m.user_b)), '[]')
  );
end $$;

-- ---------------------------------------------------------------------
-- Funciones de admin
-- ---------------------------------------------------------------------
create function public.admin_counts() returns jsonb
  language plpgsql stable security definer set search_path = public as $$
begin
  perform _require_admin();
  return jsonb_build_object(
    'verifications', (select count(*) from verification_requests where status = 'pending'),
    'reports',       (select count(*) from reports where status = 'open'),
    'photos',        (select count(*) from photo_reviews where status = 'pending'));
end $$;

create function public.admin_pending_verifications() returns setof jsonb
  language plpgsql stable security definer set search_path = public as $$
begin
  perform _require_admin();
  return query
  select jsonb_build_object(
           'id', v.id, 'user_id', v.user_id, 'pose', v.pose,
           'selfie_path', v.selfie_path, 'created_at', v.created_at,
           'name', p.display_name, 'photos', p.photos)
  from verification_requests v join profiles p on p.id = v.user_id
  where v.status = 'pending'
  order by v.created_at;
end $$;

create function public.admin_review_verification(p_request uuid, p_approve boolean)
  returns void
  language plpgsql security definer set search_path = public as $$
begin
  perform _require_admin();
  perform review_verification(p_request, p_approve);
end $$;

create function public.admin_pending_photos(p_limit int default 60) returns setof jsonb
  language plpgsql stable security definer set search_path = public as $$
begin
  perform _require_admin();
  return query
  select jsonb_build_object('path', r.path, 'user_id', r.user_id,
                            'name', p.display_name, 'created_at', r.created_at)
  from photo_reviews r join profiles p on p.id = r.user_id
  where r.status = 'pending'
  order by r.created_at
  limit least(p_limit, 200);
end $$;

-- Rechazar quita la foto del perfil y avisa a la persona.
create function public.admin_review_photo(p_path text, p_approve boolean) returns void
  language plpgsql security definer set search_path = public as $$
declare
  v_user uuid;
begin
  perform _require_admin();
  update photo_reviews
  set status = case when p_approve then 'approved' else 'rejected' end, reviewed_at = now()
  where path = p_path
  returning user_id into v_user;
  if v_user is null then raise exception 'photo_not_found'; end if;
  if not p_approve then
    update profiles set photos = array_remove(photos, p_path) where id = v_user;
    insert into notifications (user_id, type) values (v_user, 'photo_rejected');
  end if;
end $$;

create function public.admin_open_reports() returns setof jsonb
  language plpgsql stable security definer set search_path = public as $$
begin
  perform _require_admin();
  return query
  select jsonb_build_object(
           'id', r.id, 'reason', r.reason, 'details', r.details, 'created_at', r.created_at,
           'reporter', rp.display_name,
           'reported_id', r.reported_id, 'reported', p.display_name, 'photos', p.photos,
           'open_against', (select count(*) from reports x
                            where x.reported_id = r.reported_id and x.status = 'open'))
  from reports r
  join profiles p on p.id = r.reported_id
  left join profiles rp on rp.id = r.reporter_id
  where r.status = 'open'
  order by r.created_at;
end $$;

create function public.admin_dismiss_report(p_report uuid) returns void
  language plpgsql security definer set search_path = public as $$
begin
  perform _require_admin();
  update reports set status = 'dismissed' where id = p_report;
end $$;

-- Bloquea la cuenta: no puede entrar, sale de Descubrir, se anulan sus
-- solicitudes y se disuelve su pareja.
create function public.admin_ban_user(p_user uuid) returns void
  language plpgsql security definer set search_path = public as $$
declare
  v_match uuid;
begin
  perform _require_admin();
  update profiles set banned_at = now() where id = p_user
  returning current_match_id into v_match;
  if not found then raise exception 'target_not_found'; end if;
  update auth.users set banned_until = 'infinity' where id = p_user;
  update requests set status = 'voided', resolved_at = now()
  where status = 'pending' and p_user in (sender_id, receiver_id);
  if v_match is not null then perform _dissolve(v_match); end if;
  update reports set status = 'reviewed' where reported_id = p_user and status = 'open';
end $$;

-- ---------------------------------------------------------------------
-- Permisos de ejecución
-- ---------------------------------------------------------------------
revoke execute on function public.is_admin()                           from public, anon;
revoke execute on function public._require_admin()                     from public, anon, authenticated;
revoke execute on function public._queue_photos()                      from public, anon, authenticated;
revoke execute on function public._maybe_boost()                       from public, anon, authenticated;
revoke execute on function public.track_usage(int)                     from public, anon;
revoke execute on function public.submit_match_feedback(uuid, text, text) from public, anon;
revoke execute on function public.my_insights()                        from public, anon;
revoke execute on function public.admin_counts()                       from public, anon;
revoke execute on function public.admin_pending_verifications()        from public, anon;
revoke execute on function public.admin_review_verification(uuid, boolean) from public, anon;
revoke execute on function public.admin_pending_photos(int)            from public, anon;
revoke execute on function public.admin_review_photo(text, boolean)    from public, anon;
revoke execute on function public.admin_open_reports()                 from public, anon;
revoke execute on function public.admin_dismiss_report(uuid)           from public, anon;
revoke execute on function public.admin_ban_user(uuid)                 from public, anon;
