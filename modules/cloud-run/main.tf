# Service account para el CMS
resource "google_service_account" "cms" {
  account_id   = "dp-proj-00-03-cms"
  display_name = "dp-proj-00-03 CMS Service Account"
  project      = var.gcp_project_id
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

# Servicio Cloud Run del CMS (imagen y variables de entorno las gestiona dp-proj-00-03-back CI/CD)
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
        cpu_idle          = true # Request-based billing (solo CPU/memoria en peticiones)
        startup_cpu_boost = true
      }

      ports {
        container_port = var.container_port
      }

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

      # TCP: Next/Payload pueden tardar >60s en cold start; HTTP /api/health fallaba el deploy.
      startup_probe {
        tcp_socket {
          port = var.container_port
        }
        initial_delay_seconds = 0
        period_seconds        = 10
        failure_threshold     = 30
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
      template[0].containers[0].image,
      template[0].containers[0].env,
    ]
  }
}

resource "google_cloud_run_v2_service_iam_member" "public" {
  project  = var.gcp_project_id
  location = var.gcp_region
  name     = google_cloud_run_v2_service.cms.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

resource "google_artifact_registry_repository" "cms" {
  location      = var.gcp_region
  repository_id = "dp-proj-00-03-cms"
  format        = "DOCKER"
  project       = var.gcp_project_id
  description   = "Imagenes Docker del CMS Payload"
}
