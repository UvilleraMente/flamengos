// Edge Function `push`: envía una notificación de Flamengos a todos los
// dispositivos del usuario mediante Firebase Cloud Messaging (API HTTP v1).
//
// La llama el trigger `notifications_push` (migración 0004) con
// { notification_id }. No confía en el cuerpo: lee la notificación con la
// service role y solo envía si es reciente y no se envió antes.
//
// Secretos (Supabase → Edge Functions → Secrets):
//   FIREBASE_SERVICE_ACCOUNT  JSON de la cuenta de servicio de Firebase
// SUPABASE_URL y SUPABASE_SERVICE_ROLE_KEY los inyecta Supabase.
//
// Desplegar:  npx supabase functions deploy push --no-verify-jwt

import { createClient } from "npm:@supabase/supabase-js@2";

type Locale = "es" | "en";
type NotificationType =
  | "request_received"
  | "request_accepted"
  | "request_expiring"
  | "dissolution_requested"
  | "dissolution_cancelled"
  | "couple_dissolved"
  | "photo_rejected"
  | "boost_started"
  | "daily_picks"
  | "new_nearby"
  | "daily_answer";

// Mismos textos que la app (lib/l10n/app_*.arb → notif*).
type Data = { count?: number } | null;
const texts: Record<Locale, Record<NotificationType, (name: string, data: Data) => string>> = {
  es: {
    request_received: (n) => `${n} te pidió pareja`,
    request_accepted: (n) => `${n} aceptó ser tu pareja`,
    request_expiring: (n) => `La solicitud de ${n} expira pronto`,
    dissolution_requested: (n) => `${n} quiere terminar la pareja`,
    dissolution_cancelled: (n) => `${n} se arrepintió: siguen juntos`,
    couple_dissolved: (n) => `Tu pareja con ${n} terminó`,
    photo_rejected: () => "Quitamos una de tus fotos porque no cumple las normas",
    boost_started: () => "Tu perfil tiene un impulso de 24 h: saldrás primero en Descubrir",
    daily_picks: () => "Tus flamengos del día están listos",
    new_nearby: (_, d) => `Hay ${d?.count ?? "nuevas"} personas nuevas cerca que comparten tus gustos`,
    daily_answer: (n) => `${n} respondió la pregunta del día`,
  },
  en: {
    request_received: (n) => `${n} asked you to pair`,
    request_accepted: (n) => `${n} accepted to be your pair`,
    request_expiring: (n) => `${n}'s request expires soon`,
    dissolution_requested: (n) => `${n} wants to end the pair`,
    dissolution_cancelled: (n) => `${n} changed their mind: you're still together`,
    couple_dissolved: (n) => `Your pair with ${n} ended`,
    photo_rejected: () => "We removed one of your photos because it breaks the rules",
    boost_started: () => "Your profile has a 24 h boost: you'll show up first in Discover",
    daily_picks: () => "Your daily flamingos are ready",
    new_nearby: (_, d) => `${d?.count ?? "Some"} new people nearby share your interests`,
    daily_answer: (n) => `${n} answered today's question`,
  },
};
const someone: Record<Locale, string> = { es: "Alguien", en: "Someone" };

const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
);

// Se lee al primer uso: si el secreto falta o está mal, la función responde
// con un error claro en vez de caerse al arrancar.
let _serviceAccount: { client_email: string; private_key: string; project_id: string } | null =
  null;
function serviceAccount() {
  if (!_serviceAccount) {
    const raw = Deno.env.get("FIREBASE_SERVICE_ACCOUNT");
    if (!raw) throw new Error("Falta el secreto FIREBASE_SERVICE_ACCOUNT");
    _serviceAccount = JSON.parse(raw);
  }
  return _serviceAccount!;
}

// ---------- OAuth para FCM (JWT firmado con la cuenta de servicio) ----------

const b64url = (data: string | Uint8Array) =>
  btoa(
    typeof data === "string"
      ? data
      : String.fromCharCode(...data),
  ).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");

const pemToDer = (pem: string) =>
  Uint8Array.from(
    atob(pem.replace(/-----[^-]+-----/g, "").replace(/\s+/g, "")),
    (c) => c.charCodeAt(0),
  );

let cached: { token: string; expiresAt: number } | null = null;

async function accessToken(): Promise<string> {
  if (cached && cached.expiresAt > Date.now() + 60_000) return cached.token;

  const now = Math.floor(Date.now() / 1000);
  const unsigned = `${b64url(JSON.stringify({ alg: "RS256", typ: "JWT" }))}.${
    b64url(JSON.stringify({
      iss: serviceAccount().client_email,
      scope: "https://www.googleapis.com/auth/firebase.messaging",
      aud: "https://oauth2.googleapis.com/token",
      iat: now,
      exp: now + 3600,
    }))
  }`;
  const key = await crypto.subtle.importKey(
    "pkcs8",
    pemToDer(serviceAccount().private_key),
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const signature = new Uint8Array(
    await crypto.subtle.sign("RSASSA-PKCS1-v1_5", key, new TextEncoder().encode(unsigned)),
  );

  const res = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: `${unsigned}.${b64url(signature)}`,
    }),
  });
  if (!res.ok) throw new Error(`OAuth ${res.status}: ${await res.text()}`);
  const json = await res.json();
  cached = { token: json.access_token, expiresAt: Date.now() + json.expires_in * 1000 };
  return cached.token;
}

// ---------- Envío ----------

async function send(token: string, title: string, body: string, type: string) {
  const res = await fetch(
    `https://fcm.googleapis.com/v1/projects/${serviceAccount().project_id}/messages:send`,
    {
      method: "POST",
      headers: {
        Authorization: `Bearer ${await accessToken()}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        message: {
          token,
          notification: { title, body },
          data: { type },
          android: { priority: "high", notification: { color: "#FF5C93" } },
          apns: { payload: { aps: { sound: "default" } } },
          webpush: { fcm_options: { link: "/" } },
        },
      }),
    },
  );
  if (res.ok) return "sent";
  const error = await res.text();
  // Token viejo o desinstalado: lo borramos.
  if (res.status === 404 || error.includes("UNREGISTERED")) return "stale";
  console.error(`FCM ${res.status}: ${error}`);
  return "error";
}

Deno.serve(async (req) => {
  try {
    return await handle(req);
  } catch (e) {
    console.error(e);
    return Response.json({ error: String(e) }, { status: 500 });
  }
});

async function handle(req: Request): Promise<Response> {
  const { notification_id } = await req.json().catch(() => ({}));
  if (typeof notification_id !== "number") {
    return new Response("notification_id requerido", { status: 400 });
  }

  // Reclama la notificación de forma atómica: solo una vez y solo si es reciente.
  const { data: n } = await supabase
    .from("notifications")
    .update({ pushed_at: new Date().toISOString() })
    .eq("id", notification_id)
    .is("pushed_at", null)
    .gt("created_at", new Date(Date.now() - 10 * 60_000).toISOString())
    .select("user_id, type, actor_id, data")
    .maybeSingle();
  if (!n) return new Response("skip");

  const [{ data: tokens }, { data: actor }] = await Promise.all([
    supabase.from("push_tokens").select("token, locale").eq("user_id", n.user_id),
    n.actor_id
      ? supabase.from("profiles").select("display_name").eq("id", n.actor_id).maybeSingle()
      : Promise.resolve({ data: null }),
  ]);

  const results = await Promise.all(
    (tokens ?? []).map(async ({ token, locale }) => {
      const lang: Locale = locale === "en" ? "en" : "es";
      const text = texts[lang][n.type as NotificationType];
      if (!text) return "error";
      const result = await send(
        token,
        "Flamengos",
        text(actor?.display_name ?? someone[lang], n.data as Data),
        n.type,
      );
      if (result === "stale") {
        await supabase.from("push_tokens").delete().eq("token", token);
      }
      return result;
    }),
  );

  return Response.json({ results });
}
