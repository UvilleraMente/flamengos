-- =====================================================================
-- Flamengos — 0002
--   * Ubicación aproximada + filtros de búsqueda (edad, distancia, zona)
--   * Bloquear y reportar
--   * Notificaciones (bandeja en la app; base para push)
--   * Preguntas de perfil
--   * Verificación con selfie
--   * Errores como CÓDIGOS (la app los traduce a cada idioma)
--
-- Ejecutar completo en: Supabase → SQL Editor → New query → Run.
-- Requiere haber ejecutado 0001_init.sql antes.
-- =====================================================================

-- ---------------------------------------------------------------------
-- Perfiles: ubicación, preferencias de búsqueda, preguntas, verificado
-- ---------------------------------------------------------------------
alter table public.profiles
  -- Ubicación APROXIMADA (cuadrícula de ~2 km). La exacta nunca se guarda.
  add column lat double precision check (lat between -90 and 90),
  add column lng double precision check (lng between -180 and 180),
  add column location_updated_at timestamptz,
  -- Preferencias de búsqueda
  add column age_min int not null default 18 check (age_min between 18 and 99),
  add column age_max int not null default 99 check (age_max between 18 and 99),
  add column max_distance_km int default 50 check (max_distance_km between 1 and 1000),
  -- Centro de búsqueda personalizado ("buscar en otra zona"); null = mi ubicación
  add column search_lat double precision check (search_lat between -90 and 90),
  add column search_lng double precision check (search_lng between -180 and 180),
  add column search_label text check (char_length(search_label) <= 80),
  -- [{"q": "ideal_date", "a": "..."}], máximo 3
  add column prompts jsonb not null default '[]' check (
    jsonb_typeof(prompts) = 'array'
    and jsonb_array_length(prompts) <= 3
    and octet_length(prompts::text) <= 2000
  ),
  -- Solo lo cambia review_verification() (admin)
  add column verified boolean not null default false,
  add constraint profiles_age_range check (age_min <= age_max),
  add constraint profiles_search_center check ((search_lat is null) = (search_lng is null));

grant insert (prompts) on public.profiles to authenticated;
grant update (age_min, age_max, max_distance_km, search_lat, search_lng, search_label, prompts)
  on public.profiles to authenticated;

-- Guarda la ubicación redondeada a una cuadrícula de 0.02° (~2 km).
create function public.set_location(p_lat double precision, p_lng double precision)
  returns void language sql security definer set search_path = public as $$
  update profiles
  set lat = round(p_lat * 50) / 50,
      lng = round(p_lng * 50) / 50,
      location_updated_at = now()
  where id = auth.uid();
$$;

create function public.distance_km(
  lat1 double precision, lng1 double precision,
  lat2 double precision, lng2 double precision
) returns double precision language sql immutable parallel safe as $$
  select 2 * 6371 * asin(least(1, sqrt(
    power(sin(radians(lat2 - lat1) / 2), 2)
    + cos(radians(lat1)) * cos(radians(lat2)) * power(sin(radians(lng2 - lng1) / 2), 2)
  )));
$$;

-- ---------------------------------------------------------------------
-- Bloqueos y reportes
-- ---------------------------------------------------------------------
create table public.blocks (
  blocker_id uuid not null references public.profiles (id) on delete cascade,
  blocked_id uuid not null references public.profiles (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (blocker_id, blocked_id),
  check (blocker_id <> blocked_id)
);

create type public.report_reason as enum (
  'fake_profile', 'inappropriate_content', 'harassment', 'underage', 'spam', 'other'
);

create table public.reports (
  id          uuid primary key default gen_random_uuid(),
  reporter_id uuid not null references public.profiles (id) on delete cascade,
  reported_id uuid not null references public.profiles (id) on delete cascade,
  reason      public.report_reason not null,
  details     text check (char_length(details) <= 1000),
  status      text not null default 'open' check (status in ('open', 'reviewed', 'dismissed')),
  created_at  timestamptz not null default now()
);

alter table public.blocks  enable row level security;
alter table public.reports enable row level security;
revoke insert, update, delete on public.blocks from anon, authenticated;
revoke all on public.reports from anon, authenticated;

create policy "blocks: ver los míos" on public.blocks
  for select to authenticated using (blocker_id = auth.uid());

create function public.is_blocked_between(a uuid, b uuid) returns boolean
  language sql stable security definer set search_path = public as $$
  select exists (
    select 1 from blocks
    where (blocker_id = a and blocked_id = b) or (blocker_id = b and blocked_id = a)
  );
$$;

-- Si alguien te bloquea, deja de poder ver tu perfil.
create function public.has_blocked(p_blocker uuid, p_blocked uuid) returns boolean
  language sql stable security definer set search_path = public as $$
  select exists (select 1 from blocks where blocker_id = p_blocker and blocked_id = p_blocked);
$$;

drop policy "profiles: leer" on public.profiles;
create policy "profiles: leer" on public.profiles
  for select to authenticated
  using (id = auth.uid() or not public.has_blocked(id, auth.uid()));

-- ---------------------------------------------------------------------
-- Notificaciones
-- ---------------------------------------------------------------------
create type public.notification_type as enum (
  'request_received', 'request_accepted', 'request_expiring',
  'dissolution_requested', 'dissolution_cancelled', 'couple_dissolved'
);

create table public.notifications (
  id         bigint generated always as identity primary key,
  user_id    uuid not null references public.profiles (id) on delete cascade,
  type       public.notification_type not null,
  actor_id   uuid references public.profiles (id) on delete set null,
  created_at timestamptz not null default now(),
  read_at    timestamptz
);
create index notifications_by_user on public.notifications (user_id, created_at desc);

alter table public.notifications enable row level security;
revoke insert, update, delete on public.notifications from anon, authenticated;
create policy "notifications: leer las mías" on public.notifications
  for select to authenticated using (user_id = auth.uid());

alter table public.requests add column expiry_warned boolean not null default false;

create function public._notify_requests() returns trigger
  language plpgsql security definer set search_path = public as $$
begin
  if tg_op = 'INSERT' then
    insert into notifications (user_id, type, actor_id)
    values (new.receiver_id, 'request_received', new.sender_id);
  elsif new.status = 'accepted' and old.status = 'pending' then
    insert into notifications (user_id, type, actor_id)
    values (new.sender_id, 'request_accepted', new.receiver_id);
  end if;
  return null;
end $$;

create trigger requests_notify
  after insert or update of status on public.requests
  for each row execute function public._notify_requests();

create function public._notify_matches() returns trigger
  language plpgsql security definer set search_path = public as $$
declare
  v_by uuid := coalesce(new.dissolution_requested_by, old.dissolution_requested_by);
  v_other uuid := case when v_by = new.user_a then new.user_b else new.user_a end;
begin
  if old.status = 'active' and new.status = 'dissolving' then
    insert into notifications (user_id, type, actor_id) values (v_other, 'dissolution_requested', v_by);
  elsif old.status = 'dissolving' and new.status = 'active' then
    insert into notifications (user_id, type, actor_id) values (v_other, 'dissolution_cancelled', v_by);
  elsif old.status <> 'dissolved' and new.status = 'dissolved' then
    insert into notifications (user_id, type, actor_id)
    values (new.user_a, 'couple_dissolved', new.user_b),
           (new.user_b, 'couple_dissolved', new.user_a);
  end if;
  return null;
end $$;

create trigger matches_notify
  after update of status on public.matches
  for each row execute function public._notify_matches();

create function public.mark_notifications_read() returns void
  language sql security definer set search_path = public as $$
  update notifications set read_at = now() where user_id = auth.uid() and read_at is null;
$$;

revoke execute on function public._notify_requests() from public, anon, authenticated;
revoke execute on function public._notify_matches()  from public, anon, authenticated;

-- ---------------------------------------------------------------------
-- Verificación con selfie (la aprueba un admin con review_verification)
-- ---------------------------------------------------------------------
create type public.verification_status as enum ('pending', 'approved', 'rejected');

create table public.verification_requests (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references public.profiles (id) on delete cascade,
  selfie_path text not null,
  pose        text not null check (char_length(pose) <= 40),
  status      public.verification_status not null default 'pending',
  created_at  timestamptz not null default now(),
  reviewed_at timestamptz
);

alter table public.verification_requests enable row level security;
revoke insert, update, delete on public.verification_requests from anon, authenticated;
create policy "verification: ver las mías" on public.verification_requests
  for select to authenticated using (user_id = auth.uid());

create function public.request_verification(p_path text, p_pose text) returns void
  language plpgsql security definer set search_path = public as $$
begin
  if auth.uid() is null then raise exception 'not_authenticated'; end if;
  if split_part(p_path, '/', 1) <> auth.uid()::text then raise exception 'invalid_path'; end if;
  if exists (select 1 from verification_requests
             where user_id = auth.uid() and status = 'pending') then
    raise exception 'verification_pending';
  end if;
  insert into verification_requests (user_id, selfie_path, pose)
  values (auth.uid(), p_path, p_pose);
end $$;

-- Uso (admin, desde el SQL Editor):
--   select id, user_id, pose, selfie_path from verification_requests where status = 'pending';
--   select review_verification('<id>', true);   -- o false para rechazar
create function public.review_verification(p_request uuid, p_approve boolean) returns void
  language plpgsql security definer set search_path = public as $$
declare
  v_user uuid;
begin
  update verification_requests
  set status = case when p_approve then 'approved'::verification_status
                    else 'rejected'::verification_status end,
      reviewed_at = now()
  where id = p_request and status = 'pending'
  returning user_id into v_user;
  if v_user is null then raise exception 'request_not_found'; end if;
  update profiles set verified = p_approve where id = v_user;
end $$;

revoke execute on function public.review_verification(uuid, boolean) from public, anon, authenticated;

insert into storage.buckets (id, name, public)
values ('verifications', 'verifications', false)
on conflict (id) do nothing;

create policy "verifications: subir propias" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'verifications' and (storage.foldername(name))[1] = auth.uid()::text);
create policy "verifications: ver propias" on storage.objects
  for select to authenticated
  using (bucket_id = 'verifications' and (storage.foldername(name))[1] = auth.uid()::text);

-- ---------------------------------------------------------------------
-- Funciones reescritas con códigos de error (y chequeo de bloqueos)
-- Códigos: not_authenticated, cannot_request_self, cannot_block_self,
--   profile_incomplete, already_paired, target_not_found, target_paired,
--   already_requested, target_unavailable, max_active_requests,
--   request_not_found, request_unavailable, someone_paired, not_paired,
--   no_dissolution_to_cancel, invalid_path, verification_pending
-- ---------------------------------------------------------------------
create or replace function public.housekeeping() returns void
  language plpgsql security definer set search_path = public as $$
declare
  v_match uuid;
begin
  update requests set status = 'expired', resolved_at = now()
  where status = 'pending' and expires_at <= now();

  -- Aviso "tu solicitud expira pronto" (una sola vez, 3 h antes).
  with warned as (
    update requests set expiry_warned = true
    where status = 'pending' and not expiry_warned
      and expires_at <= now() + interval '3 hours'
    returning receiver_id, sender_id
  )
  insert into notifications (user_id, type, actor_id)
  select receiver_id, 'request_expiring', sender_id from warned;

  for v_match in
    select id from matches where status = 'dissolving' and dissolve_at <= now()
  loop
    perform _dissolve(v_match);
  end loop;
end $$;

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
     >= cfg_max_active_requests() then
    raise exception 'max_active_requests';
  end if;

  insert into requests (sender_id, receiver_id) values (v_me, p_target)
  returning id into v_req;
  delete from passes where user_id = v_me and target_id = p_target;

  return jsonb_build_object('result', 'sent', 'request_id', v_req);
end $$;

create or replace function public.accept_request(p_request uuid) returns uuid
  language plpgsql security definer set search_path = public as $$
declare
  v_me     uuid := auth.uid();
  v_sender uuid;
begin
  perform housekeeping();

  select sender_id into v_sender from requests
  where id = p_request and receiver_id = v_me;
  if not found then raise exception 'request_not_found'; end if;

  perform _lock_pair(v_me, v_sender);

  perform 1 from requests
  where id = p_request and status = 'pending' and expires_at > now()
  for update;
  if not found then raise exception 'request_unavailable'; end if;

  if is_blocked_between(v_me, v_sender) then raise exception 'request_unavailable'; end if;

  if exists (select 1 from profiles
             where id in (v_me, v_sender) and current_match_id is not null) then
    raise exception 'someone_paired';
  end if;

  return _create_match(p_request, v_sender, v_me);
end $$;

create or replace function public.decline_request(p_request uuid) returns void
  language plpgsql security definer set search_path = public as $$
begin
  update requests set status = 'declined', resolved_at = now()
  where id = p_request and receiver_id = auth.uid() and status = 'pending';
  if not found then raise exception 'request_unavailable'; end if;
end $$;

create or replace function public.cancel_request(p_request uuid) returns void
  language plpgsql security definer set search_path = public as $$
begin
  update requests set status = 'cancelled', resolved_at = now()
  where id = p_request and sender_id = auth.uid() and status = 'pending';
  if not found then raise exception 'request_unavailable'; end if;
end $$;

create or replace function public.request_dissolution() returns text
  language plpgsql security definer set search_path = public as $$
declare
  v_me uuid := auth.uid();
  v_m  matches%rowtype;
begin
  perform housekeeping();

  select m.* into v_m
  from matches m join profiles p on p.current_match_id = m.id
  where p.id = v_me
  for update of m;
  if not found then raise exception 'not_paired'; end if;

  if v_m.status = 'active' then
    update matches
    set status = 'dissolving',
        dissolution_requested_by = v_me,
        dissolve_at = now() + cfg_dissolution_ttl()
    where id = v_m.id;
    return 'dissolving';
  end if;

  if v_m.dissolution_requested_by is distinct from v_me then
    perform _dissolve(v_m.id);
    return 'dissolved';
  end if;

  return 'dissolving';
end $$;

create or replace function public.cancel_dissolution() returns void
  language plpgsql security definer set search_path = public as $$
begin
  update matches m
  set status = 'active', dissolution_requested_by = null, dissolve_at = null
  from profiles p
  where p.id = auth.uid() and m.id = p.current_match_id
    and m.status = 'dissolving' and m.dissolution_requested_by = auth.uid();
  if not found then raise exception 'no_dissolution_to_cancel'; end if;
end $$;

-- Bloquear (y opcionalmente reportar). Anula solicitudes entre ambos y,
-- si eran pareja, la disuelve de inmediato.
create function public.block_user(
  p_target  uuid,
  p_reason  public.report_reason default null,
  p_details text default null
) returns void
  language plpgsql security definer set search_path = public as $$
declare
  v_me    uuid := auth.uid();
  v_match uuid;
begin
  if v_me is null then raise exception 'not_authenticated'; end if;
  if p_target = v_me then raise exception 'cannot_block_self'; end if;

  perform _lock_pair(v_me, p_target);

  insert into blocks (blocker_id, blocked_id) values (v_me, p_target)
  on conflict do nothing;

  if p_reason is not null then
    insert into reports (reporter_id, reported_id, reason, details)
    values (v_me, p_target, p_reason, nullif(trim(p_details), ''));
  end if;

  update requests set status = 'voided', resolved_at = now()
  where status = 'pending'
    and ((sender_id = v_me and receiver_id = p_target)
      or (sender_id = p_target and receiver_id = v_me));

  select m.id into v_match
  from matches m join profiles p on p.current_match_id = m.id
  where p.id = v_me and p_target in (m.user_a, m.user_b);
  if v_match is not null then perform _dissolve(v_match); end if;
end $$;

create function public.unblock_user(p_target uuid) returns void
  language sql security definer set search_path = public as $$
  delete from blocks where blocker_id = auth.uid() and blocked_id = p_target;
$$;

-- ---------------------------------------------------------------------
-- Descubrimiento con filtros. Devuelve el perfil como JSON + distance_km.
-- ---------------------------------------------------------------------
drop function public.discover(int);

create function public.discover(p_limit int default 30) returns setof jsonb
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
         || jsonb_build_object('distance_km', round(c.dist::numeric, 1))
  from candidates c, me
  where me.max_distance_km is null
     or me.c_lat is null
     or (c.dist is not null and c.dist <= me.max_distance_km)
  order by c.dist nulls last, random()
  limit least(p_limit, 100);
$$;

revoke execute on function public.discover(int)                       from public, anon;
revoke execute on function public.set_location(double precision, double precision) from public, anon;
revoke execute on function public.block_user(uuid, public.report_reason, text) from public, anon;
revoke execute on function public.unblock_user(uuid)                  from public, anon;
revoke execute on function public.mark_notifications_read()           from public, anon;
revoke execute on function public.request_verification(text, text)    from public, anon;

-- ---------------------------------------------------------------------
-- Tiempo real
-- ---------------------------------------------------------------------
alter publication supabase_realtime
  add table public.notifications, public.verification_requests;
