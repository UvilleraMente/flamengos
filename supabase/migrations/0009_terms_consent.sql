-- =====================================================================
-- Flamengos — 0009: aceptación de las reglas y los términos
--   Guarda qué versión de los términos aceptó cada cuenta y cuándo.
--   La app no deja continuar hasta aceptar la versión vigente
--   (Env.termsVersion); si los términos cambian, se vuelve a pedir.
--
-- Ejecutar completo en: Supabase → SQL Editor → Run.
-- =====================================================================

create table public.terms_acceptances (
  user_id     uuid not null references auth.users (id) on delete cascade,
  version     text not null check (char_length(version) between 1 and 20),
  accepted_at timestamptz not null default now(),
  primary key (user_id, version)
);

alter table public.terms_acceptances enable row level security;
revoke insert, update, delete on public.terms_acceptances from anon, authenticated;

create policy "terms: ver las mías" on public.terms_acceptances
  for select to authenticated using (user_id = auth.uid());

create function public.accept_terms(p_version text) returns void
  language plpgsql security definer set search_path = public as $$
begin
  if auth.uid() is null then raise exception 'not_authenticated'; end if;
  insert into terms_acceptances (user_id, version) values (auth.uid(), p_version)
  on conflict (user_id, version) do nothing;
end $$;

revoke execute on function public.accept_terms(text) from public, anon;
