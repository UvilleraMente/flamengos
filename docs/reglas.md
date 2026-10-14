# Flamengos — Reglas de emparejamiento

> Los flamencos eligen una sola pareja. En Flamengos puedes coquetear con varios,
> pero cuando hay match, es **exclusivo**.

## Conceptos

- **Flamengo**: un usuario.
- **Solicitud**: un flamengo le pide pareja a otro.
- **Pareja (match)**: dos flamengos que aceptaron estar juntos. Es exclusiva.

## Estados de un flamengo

| Estado         | Ve perfiles | Envía solicitudes | Recibe solicitudes | Aparece en descubrimiento |
|----------------|:-----------:|:-----------------:|:------------------:|:-------------------------:|
| `libre`        | ✅          | ✅                | ✅                 | ✅                        |
| `emparejado`   | ❌          | ❌                | ❌                 | ❌                        |
| `disolviendo`  | ❌          | ❌                | ❌                 | ❌                        |

## Solicitudes

Estados: `pendiente` → `aceptada` | `declinada` | `cancelada` | `expirada` | `anulada`

1. Un flamengo `libre` puede enviar **varias** solicitudes a la vez (máximo `MAX_SOLICITUDES_ACTIVAS`).
2. Un flamengo `libre` puede recibir **varias** solicitudes a la vez.
3. Cada solicitud **expira sola** a las `TTL_SOLICITUD` horas (rango permitido: 24–72 h).
4. Quien envía puede **cancelarla** en cualquier momento (se cansó de esperar).
5. Quien recibe puede **aceptarla** o **declinarla**.
6. Si A le envía a B y B ya le había enviado a A → **match inmediato**.
7. No se puede enviar una solicitud a alguien que no esté `libre`.

## Al aceptar (operación atómica)

Cuando B acepta la solicitud de A, en una sola transacción:

1. La solicitud pasa a `aceptada` y se crea la pareja A–B.
2. A y B pasan a `emparejado`.
3. **Todas** las demás solicitudes `pendiente` donde A o B sean emisor o receptor pasan a `anulada`
   (se liberan las que B recibió y se limpian las que A envió, y viceversa).
4. Ambos desaparecen del descubrimiento.

> Se hace en el servidor (función Postgres con bloqueo de filas) para evitar
> que dos personas acepten al mismo flamengo al mismo tiempo.

## Disolver una pareja

- **Los dos quieren terminar** → se disuelve **inmediatamente**.
- **Solo uno quiere terminar** → la pareja pasa a `disolviendo` y se disuelve
  a las `TTL_DISOLUCION` horas (12 h). Durante ese tiempo:
  - el otro puede confirmar → disolución inmediata;
  - quien la pidió puede arrepentirse y cancelarla → vuelven a `emparejado`.
- Al disolverse, ambos vuelven a `libre` y pueden buscar de nuevo.

## Bloquear y reportar

- Cualquiera puede bloquear a otro flamengo. Reportar siempre bloquea también.
- Al bloquear: se anulan las solicitudes pendientes entre ambos y, si eran
  pareja, se disuelve **de inmediato** (sin las 12 h).
- Quien es bloqueado deja de ver el perfil de quien lo bloqueó, y ninguno
  aparece en el descubrimiento del otro.

## Descubrimiento

- Solo aparecen flamengos `libre`s, compatibles en ambos sentidos (género que
  busca cada uno) y dentro del rango de edad elegido.
- Distancia: alrededor de mi ubicación o de una zona elegida en el mapa.
  Sin ubicación ni zona, no se filtra por distancia.
- La ubicación se guarda **aproximada** (cuadrícula de ~2 km); la exacta nunca
  sale del dispositivo hacia la base de datos.
- Se ocultan: solicitudes pendientes entre ambos, rechazos de los últimos
  30 días y perfiles pasados en los últimos 7 días.

## Parámetros

| Parámetro                 | Valor inicial | Nota                                  |
|---------------------------|---------------|---------------------------------------|
| `TTL_SOLICITUD`           | 48 h          | Rango 24–72 h                         |
| `TTL_DISOLUCION`          | 12 h          |                                       |
| `MAX_SOLICITUDES_ACTIVAS` | 3             | Por confirmar — evita el "spam" de solicitudes |
