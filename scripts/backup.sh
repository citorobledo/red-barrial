#!/usr/bin/env bash
# Respaldo de SQLite (en caliente) y de los datos de Keycloak (con un corte de unos segundos).
set -euo pipefail
cd "$(dirname "$0")/.."

DEST="backups/$(date +%Y%m%d-%H%M%S)"
mkdir -p "$DEST"

# 1) SQLite: copia consistente con la API de backup, sin detener la app
docker compose exec -T app python - <<'PY'
import sqlite3
origen = sqlite3.connect("/data/db.sqlite3")
destino = sqlite3.connect("/data/backup.sqlite3")
with destino:
    origen.backup(destino)
destino.close()
origen.close()
PY
docker compose cp app:/data/backup.sqlite3 "$DEST/db.sqlite3"
docker compose exec -T app rm -f /data/backup.sqlite3

# 2) Keycloak (H2 en archivo): se detiene para copiar sin riesgo de corrupción
trap 'docker compose start keycloak >/dev/null 2>&1 || true' EXIT
docker compose stop keycloak
docker run --rm \
  -v red-barrial_keycloak-data:/src:ro \
  -v "$PWD/$DEST":/dst \
  alpine tar czf /dst/keycloak-data.tar.gz -C /src .

# 3) Retención: conservar los últimos 14 respaldos
ls -1d backups/*/ 2>/dev/null | head -n -14 | xargs -r rm -rf
echo "Respaldo creado en $DEST"
