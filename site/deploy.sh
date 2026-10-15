#!/usr/bin/env bash
# Publica el sitio (portada + legales) y la app web en https://flamengos-app.web.app
#   bash site/deploy.sh
set -euo pipefail
cd "$(dirname "$0")"

if grep -rq "\[\[CORREO_CONTACTO\]\]" public --include=*.html; then
  echo "Falta el correo de contacto: reemplaza [[CORREO_CONTACTO]] en site/public/*.html" >&2
  exit 1
fi

(cd ../app && flutter build web --release --base-href /app/)
rm -rf public/app && cp -r ../app/build/web public/app
firebase deploy --only hosting --project flamengos-app
