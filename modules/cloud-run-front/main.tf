resource "google_service_account" "front" {
  account_id   = "dp-proj-00-03-front"
  display_name = "dp-proj-00-03 Astro SSR frontend"
  project      = var.gcp_project_id
}

resource "google_project_iam_member" "front_log_writer" {
  project = var.gcp_project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.front.email}"
}

resource "google_cloud_run_v2_service" "front" {
  name     = "dp-proj-00-03-front"
  location = var.gcp_region
  project  = var.gcp_project_id

  template {
    service_account = google_service_account.front.email

    scaling {
      min_instance_count = var.min_instances
      max_instance_count = var.max_instances
    }

    containers {
      image = var.front_image

      resources {
        limits = {
          memory = var.memory_limit
          cpu    = var.cpu_limit
        }
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
        initial_delay_seconds = 5
        period_seconds        = 30
        failure_threshold     = 3
        timeout_seconds       = 5
      }

      # TCP: Astro/Node puede tardar >2 min en cold start; HTTP /api/health falla el deploy.
      startup_probe {
        tcp_socket {
          port = var.container_port
        }
        initial_delay_seconds = 5
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

# Invocación pública: health directo y rewrite de Firebase Hosting a Cloud Run.
# No enlazamos gcp-sa-firebasehosting aquí: esa SA se crea tras el primer uso de Hosting
# y terraform apply falla si aún no existe. Con allUsers, Hosting puede invocar el servicio.
resource "google_cloud_run_v2_service_iam_member" "public" {
  project  = var.gcp_project_id
  location = var.gcp_region
  name     = google_cloud_run_v2_service.front.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

resource "google_artifact_registry_repository" "front" {
  location      = var.gcp_region
  repository_id = "dp-proj-00-03-front"
  format        = "DOCKER"
  project       = var.gcp_project_id
  description   = "Imagenes Docker del frontend Astro SSR"
}
