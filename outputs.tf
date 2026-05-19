output "suffix" {
  description = "Sufijo del bloque de clientes desplegado"
  value       = var.suffix
}

output "gcp_project_id" {
  description = "Proyecto GCP del bloque (dp-proj-00-03-{suffix})"
  value       = var.gcp_project_id
}

output "cms_url" {
  description = "URL del servicio CMS en Cloud Run"
  value       = module.cloud_run.service_url
}

output "firebase_hosting_site" {
  description = "ID del sitio de Firebase Hosting"
  value       = module.firebase_hosting.site_id
}

output "firebase_hosting_url" {
  description = "URL por defecto del sitio Firebase Hosting"
  value       = module.firebase_hosting.default_url
}

output "front_url" {
  description = "URL directa del servicio Cloud Run del frontend"
  value       = module.cloud_run_front.service_url
}

output "front_cloud_run_service_name" {
  description = "Nombre del servicio Cloud Run del frontend (firebase.json run.serviceId)"
  value       = module.cloud_run_front.service_name
}

output "front_artifact_registry_repository" {
  description = "Ruta del repositorio Docker del frontend"
  value       = module.cloud_run_front.artifact_registry_repository
  sensitive   = true
}

output "storage_bucket" {
  description = "Nombre del bucket de Firebase Storage"
  value       = module.firebase_storage.bucket_name
}

output "neon_project_id" {
  description = "ID del proyecto Neon"
  value       = module.neon_database.project_id
}

output "neon_database_id" {
  description = "ID de la base de datos Neon"
  value       = module.neon_database.database_id
}

output "neon_database_connection_string" {
  description = "Connection string PostgreSQL (app_user, runtime CMS)"
  value       = module.neon_database.connection_string
  sensitive   = true
}

output "neon_database_owner_connection_string" {
  description = "Connection string PostgreSQL (owner, migraciones y DDL)"
  value       = module.neon_database.owner_connection_string
  sensitive   = true
}

output "ci_deployer_service_account_email" {
  description = "SA para GitHub Actions; crear clave JSON manual -> secret GCP_SA_KEY"
  value       = module.ci_deployer.service_account_email
}

output "artifact_registry_repository" {
  description = "Ruta del repositorio Docker del CMS en Artifact Registry"
  value       = module.cloud_run.artifact_registry_repository
}
