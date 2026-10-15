# Correo de la app (confirmación de cuenta y recuperar contraseña)

Supabase gratis envía muy pocos correos por hora con su servidor de prueba.
Con varios testers registrándose a la vez, a muchos no les llega el correo.
La solución es conectar un servicio de correo propio (SMTP). **Brevo** es
gratis hasta 300 correos al día y no exige tener un dominio propio.

## 1. Crear la cuenta en Brevo (5 minutos)

1. Entra a https://www.brevo.com y crea una cuenta con
   `creativeminds.devs@gmail.com`.
2. **Remitente:** menú de tu perfil → *Senders, Domains & Dedicated IPs* →
   *Senders* → *Add a sender*:
   - From name: `Flamengos`
   - From email: `creativeminds.devs@gmail.com`
   - Brevo te envía un código a ese correo para confirmarlo.
3. **Clave SMTP:** menú de tu perfil → *SMTP & API* → pestaña *SMTP* →
   *Generate a new SMTP key*. Copia:
   - SMTP server: `smtp-relay.brevo.com`
   - Port: `587`
   - Login: (el que muestra Brevo, termina en `@smtp-brevo.com`)
   - SMTP key: (la clave que acabas de generar; **no la compartas**)

## 2. Conectarlo en Supabase

Supabase → *Authentication* → *Emails* → *SMTP Settings* → **Enable custom SMTP**:

| Campo | Valor |
|---|---|
| Sender email | `creativeminds.devs@gmail.com` |
| Sender name | `Flamengos` |
| Host | `smtp-relay.brevo.com` |
| Port | `587` |
| Username | el *Login* de Brevo |
| Password | la *SMTP key* de Brevo |

Guarda. Luego *Authentication* → *Rate Limits* → sube **Rate limit for
sending emails** a `100` por hora.

## 3. Probar

Registra una cuenta nueva con otro correo tuyo y pide "Olvidé mi
contraseña". Deben llegar los dos correos en menos de un minuto. Si caen en
spam, márcalos como "No es spam".

## Más adelante

Con un dominio propio (por ejemplo `flamengos.app`, unos 12–15 USD al año)
los correos llegan mejor y salen desde `hola@flamengos.app`. En Brevo se
agrega el dominio y se copian 3 registros DNS; el resto queda igual.
