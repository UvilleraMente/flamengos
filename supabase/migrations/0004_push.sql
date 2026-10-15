-- =====================================================================
-- Flamengos — 0004: notificaciones push (Firebase Cloud Messaging)
--
-- Flujo: insert en notifications → trigger → pg_net llama a la Edge
-- Function `push` → la función envía a cada dispositivo del usuario.
--
-- Ejecutar completo en: Supabase → SQL Editor → New query → Run.
-- Requiere 0001–0003 y la Edge Function `push` desplegada
-- (supabase/functions/push).
-- =====================================================================

create extension if not exists pg_net;

-- Un registro por dispositivo. Si otra cuenta entra en el mismo dispositivo,
-- el token pasa a esa cuenta.
create table public.push_tokens (
  token      text primary key check (char_length(token) <= 4096),
  user_id    uuid not null references public.profiles (id) on delete cascade,
  platform   text not null check (platform in ('android', 'ios', 'web')),
  locale     text not null default 'es' check (locale in ('es', 'en')),
  updated_at timestamptz not null default now()
);
create index push_tokens_by_user on public.push_tokens (user_id);

alter table public.push_tokens enable row level security;
revoke all on public.push_tokens from anon, authenticated;

create function public.register_push_token(
  p_token text, p_platform text, p_locale text
) returns void
  language sql security definer set search_path = public as $$
  insert into push_tokens (token, user_id, platform, locale)
  values (p_token, auth.uid(), p_platform, p_locale)
  on conflict (token) do update
  set user_id = excluded.user_id,
      platform = excluded.platform,
      locale = excluded.locale,
      updated_at = now();
$$;

create function public.unregister_push_token(p_token text) returns void
  language sql security definer set search_path = public as $$
  delete from push_tokens where token = p_token and user_id = auth.uid();
$$;

revoke execute on function public.register_push_token(text, text, text) from public, anon;
revoke execute on function public.unregister_push_token(text) from public, anon;

-- Marca de envío: la función solo envía notificaciones recientes y aún no
-- enviadas, así que llamarla de más (o desde fuera) no genera spam.
alter table public.notifications add column pushed_at timestamptz;

create function public._push_notification() returns trigger
  language plpgsql security definer set search_path = public as $$
begin
  if exists (select 1 from push_tokens where user_id = new.user_id) then
    perform net.http_post(
      url := 'https://rwtaqddyfgeyueiqkjfr.supabase.co/functions/v1/push',
      body := jsonb_build_object('notification_id', new.id),
      headers := '{"Content-Type": "application/json"}'::jsonb,
      timeout_milliseconds := 5000
    );
  end if;
  return null;
end $$;

revoke execute on function public._push_notification() from public, anon, authenticated;

create trigger notifications_push
  after insert on public.notifications
  for each row execute function public._push_notification();
