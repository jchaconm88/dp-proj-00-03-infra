output "site_id" {
  description = "ID del sitio de Firebase Hosting"
  value       = google_firebase_hosting_site.main.site_id
}

output "default_url" {
  description = "URL por defecto del sitio de Firebase Hosting"
  value       = "https://${google_firebase_hosting_site.main.site_id}.web.app"
}
