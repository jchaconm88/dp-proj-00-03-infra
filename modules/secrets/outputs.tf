output "database_url_secret_id" {
  description = "ID del secreto DATABASE_URL en Secret Manager"
  value       = google_secret_manager_secret.database_url.secret_id
}

output "payload_secret_key_secret_id" {
  description = "ID del secreto PAYLOAD_SECRET_KEY en Secret Manager"
  value       = google_secret_manager_secret.payload_secret_key.secret_id
}

output "internal_api_token_secret_id" {
  description = "ID del secreto INTERNAL_API_TOKEN en Secret Manager"
  value       = google_secret_manager_secret.internal_api_token.secret_id
}

output "resend_api_key_secret_id" {
  description = "ID del secreto RESEND_API_KEY en Secret Manager"
  value       = google_secret_manager_secret.resend_api_key.secret_id
}
