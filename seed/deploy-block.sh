#!/usr/bin/env bash
# Despliega la plataforma (Cloud Run, Firebase, Neon, etc.) en UN bloque por sufijo.
# Uso: bash seed/deploy-block.sh <suffix>
set -euo pipefail

SUFFIX="${1:-}"
if [[ ! "$SUFFIX" =~ ^[a-f0-9]{4}$ ]]; then
  echo "ERROR: Uso: bash seed/deploy-block.sh <suffix>   (4 hex, ej. a1b2)"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
SEED_TF_DIR="$SCRIPT_DIR/terraform"
ENV_FILE="$SCRIPT_DIR/.env"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "ERROR: Falta $ENV_FILE (copia .env.example)."
  exit 1
fi
# shellcheck disable=SC1090
source "$ENV_FILE"

for var in NEON_API_KEY NEON_ORG_ID ALERT_EMAIL GCP_REGION; do
  if [[ -z "${!var:-}" ]]; then
    echo "ERROR: $var no definida en .env"
    exit 1
  fi
done

if [[ ! -d "$SEED_TF_DIR/.terraform" ]]; then
  echo "ERROR: Ejecuta primero bash seed/deploy.sh (bootstrap)."
  exit 1
fi

if ! terraform -chdir="$SEED_TF_DIR" output -json suffixes | \
  python -c "import json,sys; sys.exit(0 if sys.argv[1] in json.load(sys.stdin) else 1)" "$SUFFIX"; then
  echo "ERROR: El sufijo '$SUFFIX' no esta en suffixes.auto.tfvars. Ejecuta: bash seed/add-suffix.sh"
  exit 1
fi

GCP_PROJECT_ID="$(terraform -chdir="$SEED_TF_DIR" output -json block_project_ids | \
  python -c "import json,sys; print(json.load(sys.stdin)['$SUFFIX'])")"
STATE_BUCKET="$(terraform -chdir="$SEED_TF_DIR" output -json platform_state_buckets | \
  python -c "import json,sys; print(json.load(sys.stdin)['$SUFFIX'])")"
STATE_PREFIX="platform/${SUFFIX}"

echo "================================================"
echo "  Plataforma dp-proj-00-03 — sufijo: $SUFFIX"
echo "  Proyecto GCP: $GCP_PROJECT_ID"
echo "  State: gs://${STATE_BUCKET}/${STATE_PREFIX}"
echo "================================================"

cd "$ROOT_DIR"
terraform init \
  -backend-config="bucket=${STATE_BUCKET}" \
  -backend-config="prefix=${STATE_PREFIX}" \
  -reconfigure

# Imagen real del CMS cuando exista en Artifact Registry; si no, hello publico de Cloud Run
CMS_IMAGE="${CMS_IMAGE:-us-docker.pkg.dev/cloudrun/container/hello}"
if [[ "$CMS_IMAGE" == *"cloudrun/container/hello"* ]]; then
  CMS_CONTAINER_PORT=8080
  CMS_HEALTH_PATH=/
else
  CMS_CONTAINER_PORT="${CMS_CONTAINER_PORT:-3000}"
  CMS_HEALTH_PATH="${CMS_HEALTH_PATH:-/api/health}"
fi

FRONT_IMAGE="${FRONT_IMAGE:-us-docker.pkg.dev/cloudrun/container/hello}"
if [[ "$FRONT_IMAGE" == *"cloudrun/container/hello"* ]]; then
  FRONT_CONTAINER_PORT=8080
  FRONT_HEALTH_PATH=/
else
  FRONT_CONTAINER_PORT=8080
  FRONT_HEALTH_PATH=/api/health
fi

terraform plan \
  -var="suffix=${SUFFIX}" \
  -var="gcp_project_id=${GCP_PROJECT_ID}" \
  -var="gcp_region=${GCP_REGION}" \
  -var="neon_api_key=${NEON_API_KEY}" \
  -var="neon_org_id=${NEON_ORG_ID}" \
  -var="alert_email=${ALERT_EMAIL}" \
  -var="cms_image=${CMS_IMAGE}" \
  -var="cms_container_port=${CMS_CONTAINER_PORT}" \
  -var="cms_health_check_path=${CMS_HEALTH_PATH}" \
  -var="front_image=${FRONT_IMAGE}" \
  -var="front_container_port=${FRONT_CONTAINER_PORT}" \
  -var="front_health_check_path=${FRONT_HEALTH_PATH}" \
  -out="${SUFFIX}.tfplan"

read -r -p "¿Aplicar plataforma para sufijo ${SUFFIX}? (escribe 'si'): " confirm
if [[ "$confirm" != "si" ]]; then
  echo "Cancelado."
  exit 0
fi

terraform apply "${SUFFIX}.tfplan"

echo ""
echo "Configura los secretos en GitHub (repo back): ver dp-proj-00-03-back/.github/SECRETS.md"
echo "  GCP_SA_KEY: cuenta $(terraform output -raw ci_deployer_service_account_email 2>/dev/null || echo 'ci_deployer')"
echo "    -> IAM > esa cuenta > Claves > Agregar clave JSON (no la genera Terraform)"
echo "  DATABASE_URL:         terraform output -raw neon_database_connection_string"
echo "  DATABASE_URL_MIGRATE: terraform output -raw neon_database_owner_connection_string"
echo "Repo front (dp-proj-00-03-front): ver .github/SECRETS.md"
echo "  FIREBASE_HOSTING_SITE=$(terraform output -raw firebase_hosting_site 2>/dev/null || echo '?')"
echo "  GCP_REGION=${GCP_REGION}"
echo "  FRONTEND_WEBHOOK_URL (back)=https://$(terraform output -raw firebase_hosting_site 2>/dev/null).web.app/api/webhooks/rebuild"
echo "Luego push a main: back (migraciones + CMS), front (Cloud Run SSR + Hosting)."
echo ""
echo "Bloque ${SUFFIX} listo."
echo "  CMS URL: $(terraform output -raw cms_url 2>/dev/null || echo 'ver terraform output')"
