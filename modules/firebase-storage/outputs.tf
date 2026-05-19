output "bucket_name" {
  description = "Nombre del bucket de Firebase Storage"
  value       = google_storage_bucket.main.name
}

output "bucket_url" {
  description = "URL publica del bucket"
  value       = "gs://${google_storage_bucket.main.name}"
}
