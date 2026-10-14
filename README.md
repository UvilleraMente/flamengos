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

- Textos nuevos: agrégalos a `lib/l10n/app_es.arb` **y** `app_en.arb`, y úsalos
  con `context.l10n.miClave`. `flutter run` regenera el código.
- Otro idioma: crea `app_xx.arb` con las mismas claves.
- Los errores del servidor llegan como códigos (`already_paired`…) y se
  traducen en `core/errors.dart`.

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
| MapTiler | mapa (`streets-v4-dark`) y búsqueda de lugares | `MAPTILER_KEY` |

Las claves de cliente (anon key, MapTiler) viven en `app/lib/app/env.dart`.
En MapTiler, restringe la clave a tus dominios/apps
(cloud.maptiler.com → Account → Keys) para que nadie la use desde otro sitio.
