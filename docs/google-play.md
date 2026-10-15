# Publicar Flamengos en Google Play

Guía paso a paso para Play Console, con las respuestas que corresponden a lo
que la app hace hoy. Si agregas funciones (pagos, analítica, anuncios), revisa
las secciones marcadas con ⚠️.

---

## 0. Antes de empezar

| Qué | Estado |
|---|---|
| Cuenta de desarrollador (25 USD, una vez) | Pendiente |
| Sitio con privacidad, términos y borrado de cuenta | Listo para publicar (`site/`) |
| AAB firmado | `flutter build appbundle` (firma con la clave de `~/.flamengos`) |
| Ícono 512×512 | `app/assets/images/app_icon.png` (exportar a 512) |
| Gráfico destacado 1024×500 | Pendiente |
| Capturas de teléfono (mín. 2, ideal 4–8) | Pendiente (ver nota de capturas abajo) |
| Cuenta de prueba para revisores | Pendiente (crear una con perfil completo) |

### La clave de firma (¡respáldala!)
- Está en `C:\Users\<tú>\.flamengos\upload-keystore.jks` y su contraseña en
  `LEEME-respaldo.txt` de la misma carpeta (y en `app/android/key.properties`,
  que no se sube a git).
- **Respalda esa carpeta** (USB + gestor de contraseñas). Si la pierdes, Google
  permite cambiar la clave de subida, pero es un trámite lento.
- En Play Console activa **Firma de apps de Google Play** (viene por defecto):
  Google guarda la clave final y tú solo usas la de subida.

### Capturas de pantalla
Android bloquea capturas dentro de la app (privacidad, `FLAG_SECURE`). Para
las de la tienda usa la versión web (`flutter run -d chrome`, ventana de
teléfono en las DevTools) o un emulador con una compilación de depuración en la
que comentes temporalmente el bloqueo en `MainActivity.kt`.

---

## 1. Tipo de cuenta

- **Personal:** a tu nombre. Las cuentas personales nuevas deben hacer una
  **prueba cerrada con al menos 12 testers durante 14 días seguidos** antes de
  poder pedir producción.
- **Organización:** a nombre de una empresa; evita ese requisito, pero exige
  número **D-U-N-S** y una entidad legal (por ejemplo una SRL con RNC).

Tu registro en ONAPI es un **nombre comercial a título personal**
(titular: Andresnael Acevedo de la Cruz), no una sociedad. Lo más directo hoy
es la **cuenta personal**, usando "CreativeMinds by Andresnael" como nombre
del desarrollador visible. Usa la prueba cerrada como tu beta real.

---

## 2. Crear la app

- Nombre: **Flamengos**
- Idioma predeterminado: Español (Latinoamérica) — agrega Inglés (EE. UU.)
- App o juego: **App** · Gratis o de pago: **Gratis** (las compras premium
  dentro de la app se agregan después; "gratis" no se puede cambiar a "de pago").

## 3. Ficha de Play Store

**Descripción breve (máx. 80):**
> Citas con exclusividad: coquetea con varios, empareja con uno. 🦩

**Descripción completa:**
> Flamengos es la app de citas para quienes buscan algo de verdad. Como los
> flamencos, aquí la pareja es una sola.
>
> 🦩 Pide pareja hasta a 3 personas a la vez.
> 💕 Cuando alguien acepta, son exclusivos: las demás solicitudes se anulan.
> ⏳ Las solicitudes expiran en 48 horas: nadie se queda esperando.
> 💔 ¿No funcionó? Terminar toma 12 horas (o al instante si ambos quieren).
> 🗺️ Busca por edad, distancia o en otra ciudad con el mapa.
> ✅ Perfiles verificados con selfie, reportes y bloqueos.
> 🔒 Tu ubicación siempre es aproximada y la app bloquea capturas de pantalla.
> 🎨 Temas Firefly, Spicebug y Cricket (claro u oscuro), varias fuentes y tamaño de letra.
>
> Solo para mayores de 18 años.

- Categoría: **Citas** · Etiquetas: citas, relaciones
- Correo de contacto: el de soporte · Sitio web: `https://flamengos-app.web.app`

## 4. Contenido de la app (Política → Contenido de la app)

### Política de privacidad
`https://flamengos-app.web.app/privacidad`

### Acceso a la app
"Todas o algunas funciones están restringidas" → agrega **credenciales de una
cuenta de prueba** con perfil completo (y, si puedes, una segunda cuenta para
probar solicitudes y chat). Sin esto rechazan la app.

### Anuncios
**No**, la app no contiene anuncios.

### Clasificación de contenido (cuestionario IARC)
- Categoría: **Redes sociales / comunicación** (apps de citas entran aquí).
- ¿Los usuarios pueden interactuar o intercambiar contenido? **Sí** (chat,
  fotos de perfil).
- ¿Se comparte la ubicación con otros usuarios? **Sí** (aproximada).
- ¿Compras digitales? **No** (⚠️ cambiar cuando agregues premium).
- Violencia, sexo, drogas, apuestas: **No**.
Resultado esperado: clasificación para adultos / 18+.

### Público objetivo
Solo **18 años o más**. ¿Atrae a niños? **No**.

### Seguridad de los datos (Data safety)
¿Recopila o comparte datos? **Sí recopila**, **no comparte** (los proveedores
que procesan datos por cuenta tuya —Supabase, Firebase, MapTiler— no cuentan
como "compartir"). ¿Cifrado en tránsito? **Sí**. ¿Los usuarios pueden pedir
que se borren? **Sí** → `https://flamengos-app.web.app/eliminar-cuenta`.

| Tipo de dato | ¿Recopila? | Opcional | Propósito |
|---|---|---|---|
| Ubicación aproximada | Sí | Sí | Funcionalidad de la app |
| Nombre | Sí | No | Funcionalidad, gestión de la cuenta |
| Correo electrónico | Sí | No | Gestión de la cuenta |
| ID de usuario | Sí | No | Funcionalidad, gestión de la cuenta |
| Otra info personal (fecha de nacimiento, género, orientación/a quién busca, bio) | Sí | No | Funcionalidad |
| Fotos | Sí | No | Funcionalidad (perfil y verificación) |
| Mensajes en la app | Sí | No | Funcionalidad |
| Otro contenido generado por el usuario (preguntas, reportes) | Sí | Sí | Funcionalidad, seguridad |
| Interacciones en la app (solicitudes, parejas, pases) | Sí | No | Funcionalidad |
| ID del dispositivo u otros (token de notificaciones) | Sí | Sí | Funcionalidad |

⚠️ Si agregas Crashlytics/Analytics, añade "Registros de fallos" y "Diagnóstico".
⚠️ "A quién busca" puede considerarse **orientación sexual** (dato sensible):
declárala en "Información personal → Orientación sexual".

### Eliminación de la cuenta
URL: `https://flamengos-app.web.app/eliminar-cuenta`. Indica que también se
puede eliminar desde la app.

### Otras declaraciones
- Apps gubernamentales, financieras, de salud, noticias: **No**.
- ID de publicidad: **No** se usa.
- Permisos: ubicación **aproximada** solo en primer plano (no requiere
  declaración especial); cámara y notificaciones se explican solas.

## 5. Pruebas y lanzamiento

1. **Prueba interna** (hasta 100 testers, sin revisión larga): sube el primer
   AAB y pruébalo tú en un teléfono real.
2. **Prueba cerrada** (cuenta personal: ≥ 12 testers, 14 días): invita por
   correo o con un grupo de Google. Pídeles usarla de verdad y dejar opiniones.
3. **Producción**: solicita acceso cuando cumplas los 14 días; Google revisa
   (suele tardar de 1 a 7 días).

Cada versión nueva: sube `version:` en `app/pubspec.yaml` (p. ej. `1.0.1+2`;
el número después de `+` debe aumentar siempre) y vuelve a compilar.

```bash
cd app
flutter build appbundle --release --obfuscate --split-debug-info=build/symbols
# Sube: app/build/app/outputs/bundle/release/app-release.aab
# Guarda build/symbols para leer errores de producción.
```
