# Contratos de integración — dp-proj-00-03-infra

Versión de contrato: **v1**

## Outputs Terraform (consumidos por back y front)

Tras `terraform apply`, los equipos de aplicación necesitan como mínimo:

| Output / secreto | Consumidor | Uso |
|------------------|------------|-----|
| URL Cloud Run CMS | front (`CMS_URL`), back (`PAYLOAD_PUBLIC_SERVER_URL`) | API REST |
| Bucket Firebase Storage | back (`FIREBASE_STORAGE_BUCKET`) | Media y plantillas HTML |
| Firebase Hosting URL | front deploy | Sitio público |
| `DATABASE_URL` (app_user) | back | Runtime CMS |
| `DATABASE_URL_MIGRATE` (owner) | back migraciones | `pnpm db:migrate` |
| Secretos webhook | back + front | `FRONTEND_WEBHOOK_*`, `WEBHOOK_SECRET` |

## Repositorios

| Repositorio | Despliegue |
|-------------|------------|
| dp-proj-00-03-infra | Terraform validate → plan → apply (main) |
| dp-proj-00-03-back | Imagen Docker → Cloud Run |
| dp-proj-00-03-front | Build Astro → Firebase Hosting |

No incluir definiciones de aplicación en el pipeline de infra ni Terraform en los pipelines de app.

## Seed manual

Ver `seed/README` y `GUIA-OPERACION.md` en la raíz del monorepo para provisión inicial por entorno (`dev` / `qa` / `prd`).
