output "service_url" {
  description = "URL del servicio Cloud Run del CMS"
  value       = google_cloud_run_v2_service.cms.uri
}

output "service_name" {
  description = "Nombre del servicio Cloud Run"
  value       = google_cloud_run_v2_service.cms.name
}

output "service_account_email" {
  description = "Email del service account del CMS"
  value       = google_service_account.cms.email
}

output "artifact_registry_repository" {
  description = "Repositorio de Artifact Registry para imagenes del CMS"
  value       = "${var.gcp_region}-docker.pkg.dev/${var.gcp_project_id}/${google_artifact_registry_repository.cms.repository_id}"
}
