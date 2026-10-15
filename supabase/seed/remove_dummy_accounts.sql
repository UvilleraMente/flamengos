-- =====================================================================
-- Borra las cuentas de prueba (dummyNN@flamengos.test) y todo lo suyo:
-- perfiles, solicitudes, parejas, mensajes, notificaciones (en cascada).
-- Antes, borra sus fotos:  node supabase/seed/dummy_photos.mjs --remove
-- Libera sus cupos de "fundador" para los primeros 100 usuarios reales.
-- =====================================================================
delete from auth.users where email like 'dummy%@flamengos.test';

-- Comprobación: debe dar 0.
select count(*) as cuentas_de_prueba_restantes
from auth.users where email like 'dummy%@flamengos.test';
