#!/usr/bin/env bash
# Crea el esquema Payload, otorga permisos a app_user y aplica RLS.
# Uso: bash seed/scripts/setup-database.sh --owner-url "$OWNER_URL" [--back-dir path]
set -euo pipefail

OWNER_URL=""
BACK_DIR=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --owner-url)
      OWNER_URL="$2"
      shift 2
      ;;
    --back-dir)
      BACK_DIR="$2"
      shift 2
      ;;
    *)
      echo "ERROR: argumento desconocido: $1"
      exit 1
      ;;
  esac
done

if [[ -z "$OWNER_URL" ]]; then
  echo "ERROR: --owner-url es obligatorio"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SEED_DIR="$(dirname "$SCRIPT_DIR")"
SQL_DIR="$SEED_DIR/sql"

if [[ -z "$BACK_DIR" ]]; then
  BACK_DIR="$(cd "$SEED_DIR/../.." && pwd)/dp-proj-00-03-back"
fi

if [[ ! -d "$BACK_DIR" ]]; then
  echo "ERROR: No se encuentra el backend en $BACK_DIR"
  exit 1
fi

if ! command -v pnpm >/dev/null 2>&1; then
  echo "ERROR: pnpm no esta en PATH (necesario para payload migrate)"
  exit 1
fi

if [[ ! -d "$BACK_DIR/node_modules" ]]; then
  echo "Instalando dependencias del backend..."
  (cd "$BACK_DIR" && pnpm install --frozen-lockfile 2>/dev/null || pnpm install)
fi

echo "[DB] Aplicando migraciones Payload CMS..."
(
  cd "$BACK_DIR"
  DATABASE_URL="$OWNER_URL" pnpm exec payload migrate
)

if ! command -v psql >/dev/null 2>&1; then
  echo "ADVERTENCIA: psql no encontrado. Ejecuta manualmente con la URL owner:"
  echo "  psql \"\$OWNER_URL\" -f $SQL_DIR/grant-app-user.sql"
  echo "  psql \"\$OWNER_URL\" -f $SQL_DIR/rls-policies.sql"
  exit 0
fi

echo "[DB] Otorgando permisos a app_user..."
psql "$OWNER_URL" -v ON_ERROR_STOP=1 -f "$SQL_DIR/grant-app-user.sql"

echo "[DB] Aplicando politicas RLS..."
psql "$OWNER_URL" -v ON_ERROR_STOP=1 -f "$SQL_DIR/rls-policies.sql"

echo "[DB] Esquema listo (Payload + grants + RLS)."
