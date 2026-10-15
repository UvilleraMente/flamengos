// Sube (o borra) las fotos de las cuentas de prueba.
//   node supabase/seed/dummy_photos.mjs           → sube una foto a cada una
//   node supabase/seed/dummy_photos.mjs --remove  → borra sus fotos
//
// Entra como cada cuenta (correo + contraseña de dummy_accounts.sql) con la
// clave pública de la app, así que no necesita la clave de servicio. Las
// fotos quedan en el bucket "photos" de Supabase (las externas no cargan en
// la web por CORS).
import { readFileSync } from "node:fs";

const env = readFileSync(new URL("../../app/lib/app/env.dart", import.meta.url), "utf8");
const URL_ = env.match(/https:\/\/[a-z0-9]+\.supabase\.co/)[0];
const KEY = env.match(/eyJ[\w.-]+/)[0];
const PASSWORD = "Flamengos2026!";
const remove = process.argv.includes("--remove");

// Fotos de pravatar.cc revisadas a mano: 1–12 mujeres, 13–22 hombres.
const photoIds = [5, 9, 16, 20, 24, 32, 44, 47, 10, 21, 23, 25, 12, 15, 33, 52, 59, 64, 68, 11, 13, 14];

async function signIn(email) {
  const res = await fetch(`${URL_}/auth/v1/token?grant_type=password`, {
    method: "POST",
    headers: { apikey: KEY, "Content-Type": "application/json" },
    body: JSON.stringify({ email, password: PASSWORD }),
  });
  if (!res.ok) throw new Error(`${email}: ${res.status} ${await res.text()}`);
  const { access_token, user } = await res.json();
  return { token: access_token, uid: user.id };
}

async function run() {
  for (const [i, img] of photoIds.entries()) {
    const email = `dummy${String(i + 1).padStart(2, "0")}@flamengos.test`;
    const { token, uid } = await signIn(email);
    const auth = { apikey: KEY, Authorization: `Bearer ${token}` };
    const path = `${uid}/dummy-${Date.now()}.jpg`;

    if (remove) {
      // Sus fotos están en el perfil (la carpeta {uid}/ es solo suya).
      const res = await fetch(`${URL_}/rest/v1/profiles?id=eq.${uid}&select=photos`, {
        headers: auth,
      });
      const [{ photos = [] } = {}] = await res.json();
      const own = photos.filter((p) => p.startsWith(`${uid}/`));
      if (own.length) {
        await fetch(`${URL_}/storage/v1/object/photos`, {
          method: "DELETE",
          headers: { ...auth, "Content-Type": "application/json" },
          body: JSON.stringify({ prefixes: own }),
        });
      }
      console.log(`${email}: foto borrada`);
      continue;
    }

    const photo = await fetch(`https://i.pravatar.cc/800?img=${img}`);
    if (!photo.ok) throw new Error(`pravatar ${img}: ${photo.status}`);
    const bytes = Buffer.from(await photo.arrayBuffer());

    const up = await fetch(`${URL_}/storage/v1/object/photos/${path}`, {
      method: "POST",
      headers: { ...auth, "Content-Type": "image/jpeg" },
      body: bytes,
    });
    if (!up.ok) throw new Error(`${email} subir: ${up.status} ${await up.text()}`);

    const patch = await fetch(`${URL_}/rest/v1/profiles?id=eq.${uid}`, {
      method: "PATCH",
      headers: { ...auth, "Content-Type": "application/json" },
      body: JSON.stringify({ photos: [path] }),
    });
    if (!patch.ok) throw new Error(`${email} perfil: ${patch.status} ${await patch.text()}`);
    console.log(`${email}: foto lista`);
  }
}

run().catch((e) => {
  console.error(e.message);
  process.exit(1);
});
