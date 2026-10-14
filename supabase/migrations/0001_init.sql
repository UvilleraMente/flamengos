-- =====================================================================
-- Flamengos — esquema inicial
-- Implementa las reglas de docs/reglas.md.
-- Ejecutar completo en: Supabase → SQL Editor → New query → Run.
--
-- Toda escritura sobre solicitudes y parejas pasa por funciones RPC
-- (security definer). El cliente solo puede LEER esas tablas, así nadie
-- puede saltarse la exclusividad desde la app.
-- =====================================================================

-- ---------------------------------------------------------------------
-- Tipos
-- ---------------------------------------------------------------------
create type public.gender as enum ('woman', 'man', 'nonbinary');
create type public.request_status as enum (
  'pending',    -- esperando respuesta
  'accepted',   -- se convirtió en pareja
  'declined',   -- quien recibe dijo que no
  'cancelled',  -- quien envía se cansó de esperar
  'expired',    -- pasó el TTL sin respuesta
  'voided'      -- anulada porque alguno de los dos ya tiene pareja
);
create type public.match_status as enum ('active', 'dissolving', 'dissolved');

-- ---------------------------------------------------------------------
-- Parámetros (ver docs/reglas.md)
-- ---------------------------------------------------------------------
create function public.cfg_request_ttl() returns interval
  language sql immutable as $$ select interval '48 hours' $$;
create function public.cfg_dissolution_ttl() returns interval
  language sql immutable as $$ select interval '12 hours' $$;
create function public.cfg_max_active_requests() returns int
  language sql immutable as $$ select 3 $$;

-- ---------------------------------------------------------------------
-- Tablas
-- ---------------------------------------------------------------------
create table public.profiles (
  id               uuid primary key references auth.users (id) on delete cascade,
  display_name     text not null check (char_length(display_name) between 2 and 40),
  birthdate        date not null check (birthdate <= current_date - interval '18 years'),
  gender           public.gender not null,
  interested_in    public.gender[] not null check (cardinality(interested_in) > 0),
  bio              text not null default '' check (char_length(bio) <= 500),
  city             text not null default '' check (char_length(city) <= 60),
  photos           text[] not null default '{}' check (cardinality(photos) <= 6),
  -- Pareja abierta (active o dissolving). Solo la mantienen las funciones.
  current_match_id uuid,
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now()
);

create table public.requests (
  id          uuid primary key default gen_random_uuid(),
  sender_id   uuid not null references public.profiles (id) on delete cascade,
  receiver_id uuid not null references public.profiles (id) on delete cascade,
  status      public.request_status not null default 'pending',
  created_at  timestamptz not null default now(),
  expires_at  timestamptz not null default now() + public.cfg_request_ttl(),
  resolved_at timestamptz,
  check (sender_id <> receiver_id)
);
-- Como mucho una solicitud pendiente por par, en cualquier dirección.
create unique index requests_one_pending_per_pair on public.requests
  (least(sender_id, receiver_id), greatest(sender_id, receiver_id))
  where status = 'pending';
create index requests_pending_sender on public.requests (sender_id) where status = 'pending';
create index requests_pending_receiver on public.requests (receiver_id) where status = 'pending';

create table public.matches (
  id                       uuid primary key default gen_random_uuid(),
  user_a                   uuid not null references public.profiles (id) on delete cascade,
  user_b                   uuid not null references public.profiles (id) on delete cascade,
  status                   public.match_status not null default 'active',
  created_at               timestamptz not null default now(),
  dissolution_requested_by uuid references public.profiles (id) on delete set null,
  dissolve_at              timestamptz,
  dissolved_at             timestamptz,
  check (user_a < user_b)
);
create unique index matches_one_open_a on public.matches (user_a) where status <> 'dissolved';
create unique index matches_one_open_b on public.matches (user_b) where status <> 'dissolved';

alter table public.profiles
  add constraint profiles_current_match_fk
  foreign key (current_match_id) references public.matches (id) on delete set null;

-- "No me interesa": oculta un perfil del descubrimiento por 7 días.
create table public.passes (
  user_id    uuid not null references public.profiles (id) on delete cascade,
  target_id  uuid not null references public.profiles (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_id, target_id)
);

create table public.messages (
  id         bigint generated always as identity primary key,
  match_id   uuid not null references public.matches (id) on delete cascade,
  sender_id  uuid not null references public.profiles (id) on delete cascade,
  body       text not null check (char_length(body) between 1 and 2000),
  created_at timestamptz not null default now()
);
create index messages_by_match on public.messages (match_id, created_at);

create function public.touch_updated_at() returns trigger
  language plpgsql as $$
begin
  new.updated_at := now();
  return new;
end $$;

create trigger profiles_touch before update on public.profiles
  for each row execute function public.touch_updated_at();

-- ---------------------------------------------------------------------
-- Permisos y RLS
-- ---------------------------------------------------------------------
alter table public.profiles enable row level security;
alter table public.requests enable row level security;
alter table public.matches  enable row level security;
alter table public.passes   enable row level security;
alter table public.messages enable row level security;

-- profiles: lectura para usuarios autenticados; cada quien escribe el suyo,
-- pero nunca current_match_id.
revoke insert, update, delete on public.profiles from anon, authenticated;
grant insert (id, display_name, birthdate, gender, interested_in, bio, city, photos)
  on public.profiles to authenticated;
grant update (display_name, birthdate, gender, interested_in, bio, city, photos)
  on public.profiles to authenticated;

create policy "profiles: leer" on public.profiles
  for select to authenticated using (true);
create policy "profiles: crear el propio" on public.profiles
  for insert to authenticated with check (id = auth.uid());
create policy "profiles: editar el propio" on public.profiles
  for update to authenticated using (id = auth.uid()) with check (id = auth.uid());

-- requests / matches: solo lectura de lo propio. Se escriben vía RPC.
revoke insert, update, delete on public.requests from anon, authenticated;
revoke insert, update, delete on public.matches  from anon, authenticated;
revoke all on public.passes from anon, authenticated;

create policy "requests: leer las propias" on public.requests
  for select to authenticated using (auth.uid() in (sender_id, receiver_id));
create policy "matches: leer las propias" on public.matches
  for select to authenticated using (auth.uid() in (user_a, user_b));

-- messages: los dos miembros leen; escriben mientras la pareja siga abierta.
revoke update, delete on public.messages from anon, authenticated;

create function public.is_open_match_member(p_match uuid) returns boolean
  language sql stable security definer set search_path = public as $$
  select exists (
    select 1 from matches
    where id = p_match and status <> 'dissolved' and auth.uid() in (user_a, user_b)
  );
$$;

create policy "messages: leer" on public.messages
  for select to authenticated using (
    exists (select 1 from public.matches m
            where m.id = match_id and auth.uid() in (m.user_a, m.user_b))
  );
create policy "messages: escribir" on public.messages
  for insert to authenticated with check (
    sender_id = auth.uid() and public.is_open_match_member(match_id)
  );

-- ---------------------------------------------------------------------
-- Funciones internas (no expuestas al cliente)
-- ---------------------------------------------------------------------
create function public._dissolve(p_match uuid) returns void
  language plpgsql security definer set search_path = public as $$
begin
  update matches set status = 'dissolved', dissolved_at = now() where id = p_match;
  update profiles set current_match_id = null where current_match_id = p_match;
end $$;

create function public._create_match(p_request uuid, p_a uuid, p_b uuid) returns uuid
  language plpgsql security definer set search_path = public as $$
declare
  v_match uuid;
begin
  update requests set status = 'accepted', resolved_at = now() where id = p_request;

  insert into matches (user_a, user_b)
  values (least(p_a, p_b), greatest(p_a, p_b))
  returning id into v_match;

  update profiles set current_match_id = v_match where id in (p_a, p_b);

  -- Se liberan las que recibieron y se limpian las que enviaron.
  update requests set status = 'voided', resolved_at = now()
  where status = 'pending'
    and (sender_id in (p_a, p_b) or receiver_id in (p_a, p_b));

  return v_match;
end $$;

-- Bloquea los perfiles de ambos en orden fijo para evitar deadlocks
-- y carreras (dos personas aceptando al mismo flamengo a la vez).
create function public._lock_pair(p_a uuid, p_b uuid) returns void
  language plpgsql security definer set search_path = public as $$
begin
  perform 1 from profiles where id in (p_a, p_b) order by id for update;
end $$;

revoke execute on function public._dissolve(uuid)              from public, anon, authenticated;
revoke execute on function public._create_match(uuid, uuid, uuid) from public, anon, authenticated;
revoke execute on function public._lock_pair(uuid, uuid)        from public, anon, authenticated;

-- ---------------------------------------------------------------------
-- Mantenimiento: expira solicitudes y concreta disoluciones vencidas.
-- Lo llama pg_cron cada minuto y también cada RPC antes de actuar.
-- ---------------------------------------------------------------------
create function public.housekeeping() returns void
  language plpgsql security definer set search_path = public as $$
declare
  v_match uuid;
begin
  update requests set status = 'expired', resolved_at = now()
  where status = 'pending' and expires_at <= now();

  for v_match in
    select id from matches where status = 'dissolving' and dissolve_at <= now()
  loop
    perform _dissolve(v_match);
  end loop;
end $$;

-- ---------------------------------------------------------------------
-- RPC: solicitudes
-- ---------------------------------------------------------------------

-- Envía una solicitud. Si el otro ya me había enviado una → match inmediato.
-- Devuelve {"result": "sent", "request_id": ...} o {"result": "matched", "match_id": ...}
create function public.send_request(p_target uuid) returns jsonb
  language plpgsql security definer set search_path = public as $$
declare
  v_me        uuid := auth.uid();
  v_me_match  uuid;
  v_tg_match  uuid;
  v_reverse   uuid;
  v_req       uuid;
begin
  if v_me is null then raise exception 'No autenticado'; end if;
  if p_target = v_me then raise exception 'No puedes enviarte una solicitud a ti mismo'; end if;

  perform housekeeping();
  perform _lock_pair(v_me, p_target);

  select current_match_id into v_me_match from profiles where id = v_me;
  if not found then raise exception 'Completa tu perfil primero'; end if;
  if v_me_match is not null then raise exception 'Ya tienes pareja'; end if;

  select current_match_id into v_tg_match from profiles where id = p_target;
  if not found then raise exception 'Ese flamengo no existe'; end if;
  if v_tg_match is not null then raise exception 'Ese flamengo ya tiene pareja'; end if;

  select id into v_reverse from requests
  where sender_id = p_target and receiver_id = v_me and status = 'pending';
  if v_reverse is not null then
    return jsonb_build_object('result', 'matched',
                              'match_id', _create_match(v_reverse, v_me, p_target));
  end if;

  if exists (select 1 from requests
             where sender_id = v_me and receiver_id = p_target and status = 'pending') then
    raise exception 'Ya le enviaste una solicitud';
  end if;

  if exists (select 1 from requests
             where status = 'declined' and resolved_at > now() - interval '30 days'
               and ((sender_id = v_me and receiver_id = p_target)
                 or (sender_id = p_target and receiver_id = v_me))) then
    raise exception 'Ese flamengo no está disponible';
  end if;

  if (select count(*) from requests where sender_id = v_me and status = 'pending')
     >= cfg_max_active_requests() then
    raise exception 'Solo puedes tener % solicitudes activas', cfg_max_active_requests();
  end if;

  insert into requests (sender_id, receiver_id) values (v_me, p_target)
  returning id into v_req;
  delete from passes where user_id = v_me and target_id = p_target;

  return jsonb_build_object('result', 'sent', 'request_id', v_req);
end $$;

create function public.accept_request(p_request uuid) returns uuid
  language plpgsql security definer set search_path = public as $$
declare
  v_me     uuid := auth.uid();
  v_sender uuid;
begin
  perform housekeeping();

  select sender_id into v_sender from requests
  where id = p_request and receiver_id = v_me;
  if not found then raise exception 'Solicitud no encontrada'; end if;

  perform _lock_pair(v_me, v_sender);

  perform 1 from requests
  where id = p_request and status = 'pending' and expires_at > now()
  for update;
  if not found then raise exception 'Esta solicitud ya no está disponible'; end if;

  if exists (select 1 from profiles
             where id in (v_me, v_sender) and current_match_id is not null) then
    raise exception 'Uno de los dos ya tiene pareja';
  end if;

  return _create_match(p_request, v_sender, v_me);
end $$;

create function public.decline_request(p_request uuid) returns void
  language plpgsql security definer set search_path = public as $$
begin
  update requests set status = 'declined', resolved_at = now()
  where id = p_request and receiver_id = auth.uid() and status = 'pending';
  if not found then raise exception 'Esta solicitud ya no está disponible'; end if;
end $$;

create function public.cancel_request(p_request uuid) returns void
  language plpgsql security definer set search_path = public as $$
begin
  update requests set status = 'cancelled', resolved_at = now()
  where id = p_request and sender_id = auth.uid() and status = 'pending';
  if not found then raise exception 'Esta solicitud ya no está disponible'; end if;
end $$;

-- ---------------------------------------------------------------------
-- RPC: disolver pareja
-- ---------------------------------------------------------------------

-- Primera llamada: inicia la cuenta regresiva de 12 h.
-- Si el otro ya la había pedido: disolución inmediata.
-- Devuelve 'dissolving' o 'dissolved'.
create function public.request_dissolution() returns text
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
  if not found then raise exception 'No tienes pareja'; end if;

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

-- Quien pidió la disolución se arrepiente.
create function public.cancel_dissolution() returns void
  language plpgsql security definer set search_path = public as $$
begin
  update matches m
  set status = 'active', dissolution_requested_by = null, dissolve_at = null
  from profiles p
  where p.id = auth.uid() and m.id = p.current_match_id
    and m.status = 'dissolving' and m.dissolution_requested_by = auth.uid();
  if not found then raise exception 'No hay una disolución tuya que cancelar'; end if;
end $$;

-- ---------------------------------------------------------------------
-- RPC: descubrimiento
-- ---------------------------------------------------------------------
create function public.pass_profile(p_target uuid) returns void
  language sql security definer set search_path = public as $$
  insert into passes (user_id, target_id) values (auth.uid(), p_target)
  on conflict (user_id, target_id) do update set created_at = now();
$$;

-- Perfiles libres y compatibles (preferencias mutuas), en orden aleatorio.
create function public.discover(p_limit int default 20) returns setof public.profiles
  language sql stable security definer set search_path = public as $$
  select p.*
  from profiles p
  join profiles me on me.id = auth.uid()
  where p.id <> me.id
    and me.current_match_id is null
    and p.current_match_id is null
    and p.gender = any (me.interested_in)
    and me.gender = any (p.interested_in)
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
  order by random()
  limit least(p_limit, 50);
$$;

revoke execute on function public.send_request(uuid)     from public, anon;
revoke execute on function public.accept_request(uuid)   from public, anon;
revoke execute on function public.decline_request(uuid)  from public, anon;
revoke execute on function public.cancel_request(uuid)   from public, anon;
revoke execute on function public.request_dissolution()  from public, anon;
revoke execute on function public.cancel_dissolution()   from public, anon;
revoke execute on function public.pass_profile(uuid)     from public, anon;
revoke execute on function public.discover(int)          from public, anon;
revoke execute on function public.housekeeping()         from public, anon;

-- ---------------------------------------------------------------------
-- Tiempo real (la app escucha cambios en vivo)
-- ---------------------------------------------------------------------
alter publication supabase_realtime
  add table public.profiles, public.requests, public.matches, public.messages;

-- ---------------------------------------------------------------------
-- Fotos: bucket público, cada quien escribe solo en su carpeta {uid}/...
-- ---------------------------------------------------------------------
insert into storage.buckets (id, name, public)
values ('photos', 'photos', true)
on conflict (id) do nothing;

create policy "photos: subir propias" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'photos' and (storage.foldername(name))[1] = auth.uid()::text);
create policy "photos: borrar propias" on storage.objects
  for delete to authenticated
  using (bucket_id = 'photos' and (storage.foldername(name))[1] = auth.uid()::text);

-- ---------------------------------------------------------------------
-- pg_cron: mantenimiento cada minuto. Si la extensión no está disponible
-- no pasa nada: las RPC y la app también llaman a housekeeping().
-- ---------------------------------------------------------------------
do $$
begin
  create extension if not exists pg_cron;
  perform cron.schedule('flamengos-housekeeping', '* * * * *',
                        'select public.housekeeping()');
exception when others then
  raise notice 'pg_cron no disponible (%). Actívalo en Database → Extensions.', sqlerrm;
end $$;
