#!/usr/bin/env bash
# Uso: scripts/restore.sh backups/AAAAMMDD-HHMMSS
set -euo pipefail
cd "$(dirname "$0")/.."

SRC="${1:?Uso: scripts/restore.sh backups/AAAAMMDD-HHMMSS}"
[ -f "$SRC/db.sqlite3" ] || { echo "No existe $SRC/db.sqlite3"; exit 1; }

read -r -p "Esto REEMPLAZA los datos actuales. Escribí 'si' para continuar: " ok
[ "$ok" = "si" ] || { echo "Cancelado."; exit 1; }

docker compose stop app keycloak

docker run --rm \
  -v red-barrial_app-data:/data \
  -v "$PWD/$SRC":/src:ro \
  alpine sh -c 'cp /src/db.sqlite3 /data/db.sqlite3 && rm -f /data/db.sqlite3-wal /data/db.sqlite3-shm && chown 1000:1000 /data/db.sqlite3'

if [ -f "$SRC/keycloak-data.tar.gz" ]; then
  docker run --rm \
    -v red-barrial_keycloak-data:/dst \
    -v "$PWD/$SRC":/src:ro \
    alpine sh -c 'rm -rf /dst/* && tar xzf /src/keycloak-data.tar.gz -C /dst'
fi

docker compose up -d
echo "Restauración completa desde $SRC"
