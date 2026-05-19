# Vincular el proyecto GCP con Firebase (requerido antes de Hosting)
resource "google_firebase_project" "default" {
  provider = google-beta
  project  = var.gcp_project_id
}

# Firebase Hosting: sitio unico multi-dominio
# Todos los dominios personalizados de los tenants apuntan a este sitio.
# El middleware Astro SSR resuelve el tenant por request.headers.host.
resource "google_firebase_hosting_site" "main" {
  provider = google-beta
  project  = var.gcp_project_id
  site_id  = local.site_id

  depends_on = [google_firebase_project.default]
}

# Nota: Los dominios personalizados de cada tenant se configuran programaticamente
# via Firebase Hosting API cuando un tenant verifica su dominio.
# No se gestiona aqui porque son dinamicos (creados/eliminados por la app).
