# Service account para el CMS
resource "google_service_account" "cms" {
  account_id   = "dp-proj-00-03-cms"
  display_name = "dp-proj-00-03 CMS Service Account"
  project      = var.gcp_project_id
}

# Permisos del service account del CMS
resource "google_project_iam_member" "cms_secret_accessor" {
  project = var.gcp_project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.cms.email}"
}

resource "google_project_iam_member" "cms_storage_admin" {
  project = var.gcp_project_id
  role    = "roles/storage.objectAdmin"
  member  = "serviceAccount:${google_service_account.cms.email}"
}

resource "google_project_iam_member" "cms_log_writer" {
  project = var.gcp_project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.cms.email}"
}

# Servicio Cloud Run del CMS
resource "google_cloud_run_v2_service" "cms" {
  name     = "dp-proj-00-03-cms"
  location = var.gcp_region
  project  = var.gcp_project_id

  template {
    service_account = google_service_account.cms.email

    scaling {
      min_instance_count = var.min_instances
      max_instance_count = var.max_instances
    }

    containers {
      image = var.cms_image

      resources {
        limits = {
          memory = var.memory_limit
          cpu    = var.cpu_limit
        }
        startup_cpu_boost = true # Reduce cold start time
      }

      # Secrets como variables de entorno
      env {
        name = "DATABASE_URL"
        value_source {
          secret_key_ref {
            secret  = var.database_url_secret
            version = "latest"
          }
        }
      }

      env {
        name = "PAYLOAD_SECRET"
        value_source {
          secret_key_ref {
            secret  = var.payload_secret_key_secret
            version = "latest"
          }
        }
      }

      env {
        name  = "FIREBASE_STORAGE_BUCKET"
        value = var.storage_bucket
      }

      env {
        name  = "NODE_ENV"
        value = "production"
      }

      # PORT lo asigna Cloud Run segun container_port; no se puede definir manualmente
      ports {
        container_port = var.container_port
      }

      # Health check para warm-up y liveness
      liveness_probe {
        http_get {
          path = var.health_check_path
          port = var.container_port
        }
        initial_delay_seconds = 10
        period_seconds        = 30
        failure_threshold     = 3
        timeout_seconds       = 5
      }

      startup_probe {
        http_get {
          path = var.health_check_path
          port = var.container_port
        }
        initial_delay_seconds = 5
        period_seconds        = 5
        failure_threshold     = 12 # 60s max para cold start (req: 10s)
        timeout_seconds       = 5
      }
    }

    max_instance_request_concurrency = var.concurrency
    timeout                          = "${var.request_timeout}s"
  }

  traffic {
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
    percent = 100
  }

  lifecycle {
    ignore_changes = [
      # La imagen se actualiza via CI/CD de dp-proj-00-03-back
      template[0].containers[0].image,
    ]
  }
}

# Permitir invocaciones publicas al CMS (los endpoints publicos estan protegidos por la app)
resource "google_cloud_run_v2_service_iam_member" "public" {
  project  = var.gcp_project_id
  location = var.gcp_region
  name     = google_cloud_run_v2_service.cms.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

# Artifact Registry para imagenes del CMS
resource "google_artifact_registry_repository" "cms" {
  location      = var.gcp_region
  repository_id = "dp-proj-00-03-cms"
  format        = "DOCKER"
  project       = var.gcp_project_id
  description   = "Imagenes Docker del CMS Payload"
}
