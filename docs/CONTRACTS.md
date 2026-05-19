# Contratos de integración — dp-proj-00-03-infra

Versión de contrato: **v1**

## Outputs Terraform (consumidos por back y front)

Tras `terraform apply`, configurar en **GitHub Secrets** del repo back (ver `dp-proj-00-03-back/.github/SECRETS.md`):

| Output Terraform | Secret GitHub (back) | Uso |
|------------------|----------------------|-----|
| `neon_database_connection_string` | `DATABASE_URL` | Runtime CMS |
| `neon_database_owner_connection_string` | `DATABASE_URL_MIGRATE` | CI: `pnpm db:migrate` |
| `cms_url` | `PAYLOAD_PUBLIC_SERVER_URL` | URL pública CMS |
| `storage_bucket` | `FIREBASE_STORAGE_BUCKET` | Media |
| `gcp_project_id` | `GCP_PROJECT_ID`, `FIREBASE_PROJECT_ID` | GCP / Firebase |
| `ci_deployer_service_account_email` | (manual) clave JSON → `GCP_SA_KEY` | SA creada por Terraform; clave JSON en consola/gcloud |

`PAYLOAD_SECRET` y demás claves de terceros se generan/configuran manualmente en GitHub (no en GCP Secret Manager).

## Repositorios

| Repositorio | Despliegue |
|-------------|------------|
| dp-proj-00-03-infra | Terraform validate → plan → apply (main) |
| dp-proj-00-03-back | Migraciones → imagen Docker → Cloud Run (env desde GitHub) |
| dp-proj-00-03-front | Build Astro → Firebase Hosting |

No incluir definiciones de aplicación en el pipeline de infra ni Terraform en los pipelines de app.

## Seed manual

Ver `seed/deploy.sh` y `GUIA-OPERACION.md` en la raíz del monorepo para provisión inicial por bloque.
