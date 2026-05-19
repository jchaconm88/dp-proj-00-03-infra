#!/usr/bin/env bash
# =============================================================================
# Seed bootstrap: proyecto GCP seed + factory de proyectos por sufijo
# + despliegue opcional de plataforma por bloque
#
# Mapeo de sufijos: seed/terraform/suffixes.auto.tfvars
# Uso: bash seed/deploy.sh
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SEED_TF_DIR="$SCRIPT_DIR/terraform"
ENV_FILE="$SCRIPT_DIR/.env"
TFVARS="$SEED_TF_DIR/suffixes.auto.tfvars"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "ERROR: Crea $ENV_FILE copiando .env.example y completando los valores."
  exit 1
fi
# shellcheck disable=SC1090
source "$ENV_FILE"

required_vars=(
  SEED_GCP_PROJECT_ID
  SEED_TF_STATE_BUCKET
  BILLING_ACCOUNT_ID
  GCP_REGION
  NEON_API_KEY
  ALERT_EMAIL
)
for var in "${required_vars[@]}"; do
  if [[ -z "${!var:-}" ]]; then
    echo "ERROR: La variable $var no esta definida en .env"
    exit 1
  fi
done

if [[ ! -f "$TFVARS" ]]; then
  echo "ERROR: Falta $TFVARS. Copia suffixes.auto.tfvars.example o ejecuta seed/add-suffix.sh"
  exit 1
fi

DEPLOY_SUFFIXES="${DEPLOY_SUFFIXES:-}"

echo "================================================"
echo "  dp-proj-00-03 — Bootstrap (proyecto seed)"
echo "  Seed GCP: $SEED_GCP_PROJECT_ID"
echo "  Sufijos:  $(grep -E '"' "$TFVARS" | tr -d ' ",')"
echo "================================================"

echo ""
echo "[1/4] Bucket de state del bootstrap..."
if ! gcloud storage buckets describe "gs://${SEED_TF_STATE_BUCKET}" \
  --project="${SEED_GCP_PROJECT_ID}" &>/dev/null; then
  gcloud storage buckets create "gs://${SEED_TF_STATE_BUCKET}" \
    --project="${SEED_GCP_PROJECT_ID}" \
    --location="${GCP_REGION}"
fi
gcloud storage buckets update "gs://${SEED_TF_STATE_BUCKET}" --versioning

echo ""
echo "[2/4] APIs en proyecto seed..."
gcloud services enable \
  cloudresourcemanager.googleapis.com \
  cloudbilling.googleapis.com \
  serviceusage.googleapis.com \
  storage.googleapis.com \
  --project="${SEED_GCP_PROJECT_ID}" \
  --quiet

echo ""
echo "[3/4] Terraform bootstrap (proyectos por sufijo)..."
cd "$SEED_TF_DIR"
terraform init \
  -backend-config="bucket=${SEED_TF_STATE_BUCKET}" \
  -backend-config="prefix=seed/bootstrap"

terraform plan \
  -var="seed_gcp_project_id=${SEED_GCP_PROJECT_ID}" \
  -var="gcp_region=${GCP_REGION}" \
  -var="billing_account_id=${BILLING_ACCOUNT_ID}" \
  ${FOLDER_ID:+-var="folder_id=${FOLDER_ID}"} \
  -out="bootstrap.tfplan"

read -r -p "¿Aplicar bootstrap (solo sufijos nuevos en el plan)? (escribe 'si'): " confirm
if [[ "$confirm" != "si" ]]; then
  echo "Bootstrap cancelado."
  exit 0
fi

terraform apply "bootstrap.tfplan"

echo ""
echo "Bootstrap completado."
terraform output suffixes
terraform output block_project_ids
terraform output platform_state_buckets

# Desplegar plataforma: todos los sufijos del tfvars o subset DEPLOY_SUFFIXES
if [[ -z "$DEPLOY_SUFFIXES" ]]; then
  DEPLOY_SUFFIXES="$(terraform output -json suffixes | python -c "import json,sys; print(','.join(json.load(sys.stdin)))")"
fi

echo ""
echo "[4/4] Despliegue de plataforma: ${DEPLOY_SUFFIXES}"
IFS=',' read -ra SUFFIX_ARR <<< "$DEPLOY_SUFFIXES"
for suffix in "${SUFFIX_ARR[@]}"; do
  suffix="$(echo "$suffix" | tr -d '[:space:]')"
  [[ -z "$suffix" ]] && continue
  bash "$SCRIPT_DIR/deploy-block.sh" "$suffix"
done

echo ""
echo "================================================"
echo "  Seed finalizado. Mapeo: seed/terraform/suffixes.auto.tfvars"
echo "================================================"
