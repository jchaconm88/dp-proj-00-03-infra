output "service_account_email" {
  description = "Email de la SA de CI; crear clave JSON manualmente para GCP_SA_KEY en GitHub"
  value       = google_service_account.github_deploy.email
}

output "service_account_name" {
  description = "Resource name de la SA de CI"
  value       = google_service_account.github_deploy.name
}
