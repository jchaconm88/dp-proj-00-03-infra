# dp-proj-00-03-infra

Infraestructura Terraform para la plataforma web multi-tenant dp-proj-00-03.

## Descripción

Este repositorio contiene todas las definiciones de infraestructura Terraform de la plataforma:
- **Cloud Run** — Servicio Payload CMS multi-tenant
- **Firebase Hosting** — Frontend Astro SSG/SSR (sitio único multi-dominio)
- **Firebase Storage** — Bucket compartido con aislamiento por tenant
- **Neon PostgreSQL** — Base de datos compartida con Row Level Security
- **Cloud Monitoring** — Alertas, logging y monitoreo
- **Cloud Scheduler** — Publicación programada (**desactivado por defecto**; `enable_publish_scheduler`)

## Dependencias externas

| Repositorio | Interface consumida | Versión mínima | Protocolo |
|-------------|--------------------|--------------  |-----------|
| dp-proj-00-03-back | Imagen Docker del CMS | semver | Cloud Run container |
| dp-proj-00-03-front | Build estático Astro | semver | Firebase Hosting deploy |

## Estructura

```
modules/
├── cloud-run/          # Cloud Run service para Payload CMS
├── ci-deployer/        # SA GitHub Actions (deploy); clave JSON manual
├── firebase-hosting/   # Firebase Hosting (sitio único multi-dominio)
├── firebase-storage/   # Firebase Storage bucket compartido
├── neon-database/      # PostgreSQL en Neon con RLS
├── monitoring/         # Cloud Logging y alertas
└── networking/         # Dominios personalizados y SSL
seed/
└── deploy.sh           # Script de despliegue inicial manual
.github/
└── workflows/
    └── terraform.yml   # Pipeline CI/CD de infraestructura
```

## Primeros pasos

### Pre-requisitos

- Terraform >= 1.6
- Google Cloud SDK autenticado:

```bash
gcloud auth login
gcloud auth application-default login
```
- Firebase CLI (`npm install -g firebase-tools`)
- Cuenta Neon con API key

### Seed inicial (primera vez)

1. Crear manualmente el **proyecto GCP seed** (solo bootstrap: state de Terraform y factory de proyectos).
2. Vincular facturación y obtener el `BILLING_ACCOUNT_ID`.

```bash
gcloud auth login
gcloud auth application-default login
cp seed/.env.example seed/.env
# Editar seed/.env (SEED_GCP_PROJECT_ID, BILLING_ACCOUNT_ID, etc.)
bash seed/deploy.sh
```

El bootstrap usa el **mapeo de sufijos** en `seed/terraform/suffixes.auto.tfvars`.
Cada sufijo (4 hex) crea un proyecto aislado `dp-proj-00-03-{suffix}` con su propia
infra y BD (bloque de clientes). Para agregar un bloque nuevo:

```bash
bash seed/add-suffix.sh          # genera y registra un sufijo
bash seed/deploy.sh              # crea solo el proyecto nuevo
bash seed/deploy-block.sh a1b2   # despliega plataforma en ese sufijo
```

### Despliegue de cambios

Los cambios a `main` se despliegan automáticamente vía GitHub Actions.

```bash
# Validar localmente
terraform init
terraform validate
terraform plan -var-file="environments/block.tfvars" -var="gcp_project_id=dp-proj-00-03-a1b2"
```

## Variables requeridas

Ver `variables.tf` para la lista completa. Las variables sensibles se gestionan
vía GitHub Secrets (repo back para runtime CMS; ver `dp-proj-00-03-back/.github/SECRETS.md`).
