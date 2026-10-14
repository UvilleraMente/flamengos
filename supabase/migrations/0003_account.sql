-- =====================================================================
-- Flamengos — 0003: eliminar cuenta
-- Ejecutar completo en: Supabase → SQL Editor → New query → Run.
-- Requiere 0001 y 0002.
-- =====================================================================

-- La app borra las selfies de verificación antes de eliminar la cuenta.
create policy "verifications: borrar propias" on storage.objects
  for delete to authenticated
  using (bucket_id = 'verifications' and (storage.foldername(name))[1] = auth.uid()::text);

-- Elimina al usuario que llama. Si tenía pareja, primero la disuelve (así la
-- otra persona recibe el aviso). Al borrar auth.users, la base de datos borra
-- en cascada: perfil, solicitudes, pareja, mensajes, notificaciones, bloqueos.
create function public.delete_my_account() returns void
  language plpgsql security definer set search_path = public as $$
declare
  v_me    uuid := auth.uid();
  v_match uuid;
begin
  if v_me is null then raise exception 'not_authenticated'; end if;

  select current_match_id into v_match from profiles where id = v_me for update;
  if v_match is not null then perform _dissolve(v_match); end if;

  delete from auth.users where id = v_me;
end $$;

revoke execute on function public.delete_my_account() from public, anon;
