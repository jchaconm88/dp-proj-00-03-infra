output "service_url" {
  description = "URL del servicio Cloud Run del frontend"
  value       = google_cloud_run_v2_service.front.uri
}

output "service_name" {
  description = "Nombre del servicio Cloud Run (rewrite Firebase Hosting)"
  value       = google_cloud_run_v2_service.front.name
}

output "service_account_email" {
  description = "Email del service account del frontend"
  value       = google_service_account.front.email
}

output "artifact_registry_repository" {
  description = "Ruta del repositorio Docker del frontend en Artifact Registry"
  value       = "${var.gcp_region}-docker.pkg.dev/${var.gcp_project_id}/${google_artifact_registry_repository.front.repository_id}"
}
