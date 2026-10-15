-- =====================================================================
-- Flamengos — cuentas de prueba (SOLO PARA PROBAR, BORRAR ANTES DE PUBLICAR)
--
-- Crea 22 cuentas con perfil completo: correo dummyNN@flamengos.test,
-- contraseña Flamengos2026!  (puedes entrar con cualquiera para probar el
-- otro lado de una solicitud o del chat).
--
-- 1. Ejecuta este archivo en Supabase → SQL Editor → Run.
-- 2. Sube sus fotos:  node supabase/seed/dummy_photos.mjs
-- 3. Para borrarlas:  node supabase/seed/dummy_photos.mjs --remove
--                     y luego remove_dummy_accounts.sql en el SQL Editor.
--
-- Ojo: mientras existan cuentan como "fundadoras" (de las 100 premium).
-- Al borrarlas esos cupos quedan libres otra vez.
-- =====================================================================

do $$
declare
  d record;
  v_id uuid;
begin
  for d in
    select * from (values
      -- n, nombre, nacimiento, género, busca, ciudad, lat, lng, bio, etiquetas, pregunta, respuesta
      (1,  'Mariela',   date '1997-03-14', 'woman', '{man}',   'Santo Domingo', 18.47, -69.93,
       'Ingeniera de día, bachatera de noche. Busco a alguien con quien compartir un buen café y conversaciones largas.',
       '{worker,dance,foodie,serious}', 'ideal_date', 'Un cafecito en la Zona Colonial y caminar sin prisa.'),
      (2,  'Yohanna',   date '1999-07-02', 'woman', '{man}',   'Santo Domingo', 18.49, -69.91,
       'Estudiante de medicina. Me encanta la playa y los domingos en familia.',
       '{student,beach,family,christian}', 'green_flag', 'Que trate bien a su mamá.'),
      (3,  'Carolina',  date '1994-11-21', 'woman', '{man}',   'Santiago', 19.45, -70.70,
       'Emprendedora, amante de los perros y del buen mofongo.',
       '{entrepreneur,pets,foodie,wants_kids}', 'weekend', 'Montaña en Jarabacoa y una buena película.'),
      (4,  'Paola',     date '1998-01-30', 'woman', '{man}',   'Santo Domingo', 18.45, -69.95,
       'Diseñadora gráfica. Si me invitas a un concierto ya vas ganando.',
       '{worker,music,traveler}', 'song', 'Cualquier cosa de Juan Luis Guerra.'),
      (5,  'Rosmery',   date '1996-05-09', 'woman', '{man}',   'San Cristóbal', 18.42, -70.10,
       'Maestra. Tranquila, de planes en casa y series.',
       '{worker,homebody,christian,no_smoking}', 'looking_for', 'Algo serio, sin juegos.'),
      (6,  'Laura',     date '2001-09-17', 'woman', '{man}',   'Santo Domingo', 18.48, -69.88,
       'Estudio arquitectura. Gym en la mañana, café en la tarde.',
       '{student,gym,foodie}', 'unpopular_opinion', 'El mangú es mejor de cena que de desayuno.'),
      (7,  'Ana Lucía', date '1993-12-05', 'woman', '{man}',   'Punta Cana', 18.56, -68.37,
       'Trabajo en turismo. Vivo cerca del mar y no lo cambio por nada.',
       '{worker,beach,traveler,dance}', 'ideal_date', 'Atardecer en la playa con algo rico de comer.'),
      (8,  'Gabriela',  date '2000-04-22', 'woman', '{man}',   'Santo Domingo', 18.46, -69.92,
       'Lectora, gamer de closet y fan de los gatos.',
       '{reader,gamer,pets}', 'green_flag', 'Que me recomiende libros.'),
      (9,  'Nicole',    date '1995-08-11', 'woman', '{man}',   'Santiago', 19.46, -70.68,
       'Contadora. Amo bailar merengue y viajar por el país.',
       '{worker,dance,traveler,family}', 'weekend', 'Playa en Puerto Plata con amigos.'),
      (10, 'Valeria',   date '1998-10-03', 'woman', '{woman}', 'Santo Domingo', 18.47, -69.90,
       'Fotógrafa. Me gusta la naturaleza y las conversaciones honestas.',
       '{worker,nature,traveler,serious}', 'looking_for', 'Alguien con quien construir algo bonito.'),
      (11, 'Esther',    date '1992-02-18', 'woman', '{man}',   'La Romana', 18.43, -68.97,
       'Enfermera. Mujer de fe y de familia.',
       '{worker,christian,family,wants_kids,no_drinking}', 'looking_for', 'Un hombre de Dios y trabajador.'),
      (12, 'Camila',    date '2002-06-25', 'woman', '{man,woman}', 'Santo Domingo', 18.50, -69.94,
       'Estudio comunicación. Música, fiesta y buena vibra.',
       '{student,party,music,dance}', 'song', 'Algo de Rauw para empezar la noche.'),
      (13, 'Luis',      date '1995-05-12', 'man',   '{woman}', 'Santo Domingo', 18.47, -69.92,
       'Programador. Fan del béisbol y de cocinar los domingos.',
       '{worker,sports,foodie,serious}', 'ideal_date', 'Cocinar juntos y ver un juego de los Tigres.'),
      (14, 'Javier',    date '1997-08-29', 'man',   '{woman}', 'Santiago', 19.45, -70.69,
       'Médico residente. Poco tiempo libre pero bien aprovechado.',
       '{worker,gym,family}', 'green_flag', 'Que sea puntual.'),
      (15, 'Kelvin',    date '1999-12-01', 'man',   '{woman}', 'Santo Domingo', 18.49, -69.89,
       'Emprendedor, barbería propia. Me encanta la playa y el dembow.',
       '{entrepreneur,beach,music,party}', 'weekend', 'Boca Chica con los panas.'),
      (16, 'Andrés',    date '1994-03-08', 'man',   '{woman}', 'Santo Domingo', 18.45, -69.93,
       'Abogado. Lector, viajero y fiel creyente.',
       '{worker,reader,traveler,christian}', 'looking_for', 'Algo serio con alguien que comparta mi fe.'),
      (17, 'Ramón',     date '1992-10-19', 'man',   '{woman}', 'San Cristóbal', 18.41, -70.11,
       'Ingeniero civil. Hombre de casa y de familia.',
       '{worker,homebody,family,wants_kids}', 'ideal_date', 'Una cena tranquila y buena conversación.'),
      (18, 'Daniel',    date '2000-01-14', 'man',   '{woman}', 'Santo Domingo', 18.48, -69.95,
       'Estudiante de ingeniería y gamer.',
       '{student,gamer,music}', 'unpopular_opinion', 'La pizza con piña está buena.'),
      (19, 'Miguel',    date '1996-06-30', 'man',   '{woman}', 'Punta Cana', 18.57, -68.36,
       'Chef en un hotel. Si te gusta comer, nos vamos a llevar bien.',
       '{worker,foodie,beach,dance}', 'song', 'Una bachata de Romeo.'),
      (20, 'José',      date '1993-09-09', 'man',   '{woman}', 'Santiago', 19.44, -70.71,
       'Contador, deportista y madrugador.',
       '{worker,sports,gym,no_smoking}', 'green_flag', 'Que le guste el deporte.'),
      (21, 'Samuel',    date '1998-04-04', 'man',   '{woman}', 'Santo Domingo', 18.46, -69.90,
       'Músico. Toco guitarra en la iglesia los domingos.',
       '{music,christian,serious}', 'looking_for', 'Una compañera para la vida.'),
      (22, 'Ernesto',   date '1995-11-27', 'man',   '{woman}', 'La Romana', 18.42, -68.98,
       'Técnico en refrigeración. Me gusta pescar y la naturaleza.',
       '{worker,nature,beach}', 'weekend', 'Pescando en Bayahíbe.')
    ) as t(n, name, birth, gender, wants, city, lat, lng, bio, tags, q, a)
  loop
    v_id := gen_random_uuid();

    insert into auth.users (
      id, instance_id, aud, role, email, encrypted_password, email_confirmed_at,
      raw_app_meta_data, raw_user_meta_data, created_at, updated_at,
      confirmation_token, email_change, email_change_token_new, recovery_token)
    values (
      v_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
      format('dummy%s@flamengos.test', lpad(d.n::text, 2, '0')),
      extensions.crypt('Flamengos2026!', extensions.gen_salt('bf')), now(),
      '{"provider":"email","providers":["email"]}', '{}', now(), now(), '', '', '', '');

    insert into auth.identities (provider_id, user_id, identity_data, provider,
                                 last_sign_in_at, created_at, updated_at)
    values (v_id::text, v_id,
            jsonb_build_object('sub', v_id::text,
                               'email', format('dummy%s@flamengos.test', lpad(d.n::text, 2, '0')),
                               'email_verified', true),
            'email', now(), now(), now());

    insert into public.profiles (id, display_name, birthdate, gender, interested_in,
                                 bio, city, lat, lng, location_updated_at, tags, prompts)
    values (v_id, d.name, d.birth, d.gender::public.gender, d.wants::public.gender[],
            d.bio, d.city, d.lat, d.lng, now(), d.tags::text[],
            jsonb_build_array(jsonb_build_object('q', d.q, 'a', d.a)));
  end loop;
end $$;
