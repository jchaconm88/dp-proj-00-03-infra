# Bucket de Firebase Storage compartido por todos los tenants
# Estructura de rutas: tenants/{tenant_id}/media/...
resource "google_storage_bucket" "main" {
  # Nombre global unico por bloque (gcp_project_id ya incluye el sufijo)
  name          = "${var.gcp_project_id}-${var.bucket_name_suffix}"
  location      = var.storage_location
  project       = var.gcp_project_id
  force_destroy = false

  uniform_bucket_level_access = true

  cors {
    origin          = ["*"]
    method          = ["GET", "HEAD", "OPTIONS"]
    response_header = ["Content-Type", "Authorization", "x-goog-resumable"]
    max_age_seconds = 3600
  }

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      age = 365 # Eliminar archivos temporales/fallidos despues de 1 año
      matches_prefix = ["temp/"]
    }
  }
}

# Reglas de acceso: el service account del CMS tiene acceso total
# Los archivos publicos se acceden via signed URLs o reglas de Firebase Security Rules
resource "google_storage_bucket_iam_member" "public_read" {
  bucket = google_storage_bucket.main.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}
