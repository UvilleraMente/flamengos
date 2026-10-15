-- =====================================================================
-- Flamengos — 0006: responder y editar mensajes
--   * reply_to: el mensaje al que responde (del mismo chat).
--   * Editar: solo el autor, hasta 1 minuto después de enviarlo
--     (con 10 s de gracia por la latencia), mientras la pareja siga abierta.
--
-- Ejecutar completo en: Supabase → SQL Editor → New query → Run.
-- =====================================================================

alter table public.messages
  add column reply_to  bigint references public.messages (id) on delete set null,
  add column edited_at timestamptz;

create function public.cfg_message_edit_window() returns interval
  language sql immutable as $$ select interval '1 minute' $$;

-- La respuesta debe apuntar a un mensaje del mismo chat.
create function public.is_reply_in_match(p_reply bigint, p_match uuid) returns boolean
  language sql stable security definer set search_path = public as $$
  select p_reply is null
      or exists (select 1 from messages where id = p_reply and match_id = p_match);
$$;

drop policy "messages: escribir" on public.messages;
create policy "messages: escribir" on public.messages
  for insert to authenticated with check (
    sender_id = auth.uid()
    and public.is_open_match_member(match_id)
    and public.is_reply_in_match(reply_to, match_id)
  );

-- Los mensajes nuevos nunca llegan "editados".
revoke insert on public.messages from authenticated;
grant insert (match_id, sender_id, body, reply_to) on public.messages to authenticated;

create function public.edit_message(p_message bigint, p_body text) returns void
  language plpgsql security definer set search_path = public as $$
declare
  v_msg messages;
begin
  if auth.uid() is null then raise exception 'not_authenticated'; end if;

  select * into v_msg from messages where id = p_message for update;
  if not found or v_msg.sender_id <> auth.uid() then
    raise exception 'message_not_found';
  end if;
  if not is_open_match_member(v_msg.match_id) then raise exception 'not_paired'; end if;
  if now() > v_msg.created_at + cfg_message_edit_window() + interval '10 seconds' then
    raise exception 'edit_window_closed';
  end if;

  p_body := trim(p_body);
  if char_length(p_body) not between 1 and 2000 then raise exception 'message_invalid'; end if;
  if p_body = v_msg.body then return; end if;

  update messages set body = p_body, edited_at = now() where id = p_message;
end $$;

revoke execute on function public.edit_message(bigint, text)          from public, anon;
revoke execute on function public.is_reply_in_match(bigint, uuid)     from public, anon;
