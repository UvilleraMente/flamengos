# Flamengos 🦩

App de citas con exclusividad: puedes coquetear con varios, pero cuando hay
pareja, es solo una. Reglas completas en [docs/reglas.md](docs/reglas.md).

## Estructura

```
app/                          Flutter (web, Android, iOS — una sola base de código)
  lib/
    main.dart                 arranque (Supabase + intl)
    app/                      FlamengosApp, rutas (router.dart) y configuración (env.dart)
    core/                     piezas transversales
      theme/                  tokens de diseño (colores, radios, tiempos) y tema
      l10n/                   context.l10n y el idioma elegido (locale_controller)
      supabase/               cliente y usuario actual
      errors.dart             traduce códigos de error del servidor
    l10n/                     traducciones: app_es.arb (plantilla) y app_en.arb
    shared/                   sistema de componentes (Glass, FlamButton, FlamChip,
                              GlassNavBar, ProfileCard…) — importa widgets/widgets.dart
    features/<funcionalidad>/
      domain/                 modelos puros
      data/                   repositorio (Supabase/APIs) + providers de Riverpod
      presentation/           pantallas y widgets de la funcionalidad
  assets/fonts/               Outfit (texto) y Pacifico (logo), licencia OFL
supabase/migrations/          esquema SQL, en orden (0001, 0002…)
docs/reglas.md                reglas de emparejamiento
```

Funcionalidades: `auth`, `profile`, `discover` (tarjetas, mapa, filtros),
`location` (GPS, búsqueda de lugares), `requests`, `couple` (pareja y chat),
`notifications`, `safety` (bloquear y reportar), `verification` (selfie),
`settings`, `home`.

La exclusividad se impone **en la base de datos**: el cliente solo puede leer
solicitudes y parejas; toda escritura pasa por funciones RPC que bloquean filas
para evitar carreras.

## Configurar Supabase

1. **SQL Editor → New query**: ejecuta cada archivo de `supabase/migrations/`
   **en orden** (0001, luego 0002…). Cada uno se ejecuta una sola vez.
2. **Authentication → Sign In / Providers → Email**: para la demo, desactiva
   *Confirm email*.
3. **Authentication → URL Configuration → Redirect URLs**, agrega:
   - `http://localhost:*/**` (web en desarrollo)
   - `com.flamengos.flamengos://login-callback` (app Android/iOS)
   - la URL de la web cuando la publiques
4. **Authentication → Emails → Templates → Reset Password**: pega
   `supabase/templates/reset_password.html` (agrega el código de 6 dígitos).
5. **Correo real (producción)**: el SMTP de Supabase solo envía a los miembros
   del equipo y pocos correos por hora. Configura uno propio en
   **Authentication → Emails → SMTP Settings** (Resend, SendGrid, Brevo…).
6. *(Opcional)* **Database → Extensions**: verifica que `pg_cron` esté activo.

### Notificaciones push (Firebase `flamengos-app`)

Flujo: `notifications` (insert) → trigger `notifications_push` → Edge Function
[`push`](supabase/functions/push/index.ts) → Firebase Cloud Messaging.

1. Firebase → ⚙️ Configuración del proyecto → **Cuentas de servicio** →
   *Generar nueva clave privada*. Guarda el JSON **fuera del repo**.
2. Desplegar la función y guardar el secreto (una vez):
   ```bash
   npx supabase login
   npx supabase functions deploy push --no-verify-jwt --project-ref rwtaqddyfgeyueiqkjfr
   npx supabase secrets set --project-ref rwtaqddyfgeyueiqkjfr FIREBASE_SERVICE_ACCOUNT="$(cat ruta/al/archivo.json)"
   ```
3. Ejecutar `supabase/migrations/0004_push.sql`.
4. **Web** (opcional): Cloud Messaging → *Certificados push web* → generar par
   de claves y correr con `--dart-define=FIREBASE_VAPID_KEY=...`.
5. **iOS**: requiere cuenta Apple Developer y subir la clave APNs en
   Cloud Messaging → *Configuración de apps de Apple*.

### Moderación (admin, desde el SQL Editor)

```sql
-- Verificaciones pendientes (la selfie está en Storage → verifications)
select id, user_id, pose, selfie_path from verification_requests where status = 'pending';
select review_verification('<id>', true);   -- aprobar (false = rechazar)

-- Reportes
select * from reports where status = 'open' order by created_at desc;
```

## Idiomas

Español (base) e inglés. La app usa el idioma del dispositivo; se puede
cambiar en **Perfil → Ajustes → Idioma** (o en el login).

- Textos nuevos: agrégalos a `lib/l10n/app_es.arb` **y** `app_en.arb`, úsalos
  con `context.l10n.miClave` y regenera:
  `flutter gen-l10n && dart run tool/gen_text_case.dart`
  (el segundo genera la versión en MAYÚSCULAS/minúsculas/Título de Ajustes).
- Otro idioma: crea `app_xx.arb` con las mismas claves.
- Los errores del servidor llegan como códigos (`already_paired`…) y se
  traducen en `core/errors.dart`.

## Apariencia

Ajustes → Apariencia: tema (**Firefly**, **Claro**, **Oscuro**), fuente (Outfit,
Nunito, Lora, Quicksand), tamaño de letra y formato de letras. Los colores
viven en `core/theme/tokens.dart` (`FlamPalette`); usa siempre `FlamColors.*`
(nunca colores fijos) para que todo cambie con el tema. Sobre fotos o
degradados rosa usa `FlamColors.onPhoto` / `onAccent`.

## Sitio web y publicación

- `site/`: portada, privacidad, términos y borrado de cuenta (Firebase Hosting,
  `https://flamengos-app.web.app`). La app web se publica en `/app/`.
  Publicar: `bash site/deploy.sh`.
- Google Play paso a paso: [docs/google-play.md](docs/google-play.md).
- Firma de Android: `app/android/key.properties` + `~/.flamengos/upload-keystore.jks`
  (fuera del repo, **respáldalos**).

## Correr la app

```bash
cd app
flutter run -d chrome     # web
flutter run               # dispositivo o emulador Android/iOS
flutter test              # pruebas
```

La URL y la anon key de Supabase están en `app/lib/app/env.dart` y se pueden
sobreescribir con `--dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...`.

## Servicios externos

| Servicio | Para qué | Configuración |
|---|---|---|
| Supabase | auth, base de datos, tiempo real, fotos | `SUPABASE_URL`, `SUPABASE_ANON_KEY` |
| MapTiler | mapa (estilo según el tema) y búsqueda de lugares | `MAPTILER_KEY` |
| Firebase | notificaciones push y hosting del sitio | `firebase_options.dart`, `FIREBASE_VAPID_KEY` |

Las claves de cliente (anon key, MapTiler) viven en `app/lib/app/env.dart`.
En MapTiler, restringe la clave a tus dominios/apps
(cloud.maptiler.com → Account → Keys) para que nadie la use desde otro sitio.
