# Habilitar APIs de GCP necesarias
resource "google_project_service" "apis" {
  for_each = toset([
    "run.googleapis.com",
    "firebase.googleapis.com",
    "firebasehosting.googleapis.com",
    "storage.googleapis.com",
    "secretmanager.googleapis.com",
    "monitoring.googleapis.com",
    "logging.googleapis.com",
    "cloudbilling.googleapis.com",
    "cloudscheduler.googleapis.com",
    "artifactregistry.googleapis.com",
    "billingbudgets.googleapis.com",
  ])

  project            = var.gcp_project_id
  service            = each.key
  disable_on_destroy = false
}

# Modulo: Base de datos Neon PostgreSQL
module "neon_database" {
  source = "./modules/neon-database"

  org_id       = var.neon_org_id
  project_name = local.neon_project_name
  region       = "aws-us-east-1" # Neon usa regiones AWS internamente
}

# Modulo: Secret Manager
module "secrets" {
  source = "./modules/secrets"

  gcp_project_id   = var.gcp_project_id
  database_url     = module.neon_database.connection_string
  neon_api_key     = var.neon_api_key

  depends_on = [google_project_service.apis]
}

# Modulo: Firebase Storage (bucket compartido)
module "firebase_storage" {
  source = "./modules/firebase-storage"

  gcp_project_id   = var.gcp_project_id
  storage_location = var.storage_location

  depends_on = [google_project_service.apis]
}

# Modulo: Cloud Run (CMS Payload)
module "cloud_run" {
  source = "./modules/cloud-run"

  gcp_project_id    = var.gcp_project_id
  gcp_region        = var.gcp_region
  cms_image           = var.cms_image
  container_port      = var.cms_container_port
  health_check_path   = var.cms_health_check_path
  min_instances       = var.cms_min_instances
  max_instances     = var.cms_max_instances
  database_url_secret = module.secrets.database_url_secret_id
  payload_secret_key_secret = module.secrets.payload_secret_key_secret_id
  storage_bucket    = module.firebase_storage.bucket_name

  depends_on = [
    google_project_service.apis,
    module.secrets,
    module.firebase_storage,
  ]
}

# Modulo: Firebase Hosting (frontend Astro)
module "firebase_hosting" {
  source = "./modules/firebase-hosting"

  gcp_project_id      = var.gcp_project_id
  firebase_project_id = local.firebase_project_id
  suffix              = var.suffix

  depends_on = [google_project_service.apis]
}

# Modulo: Monitoreo y alertas
module "monitoring" {
  source = "./modules/monitoring"

  gcp_project_id              = var.gcp_project_id
  cloud_run_service_name      = module.cloud_run.service_name
  alert_email                 = var.alert_email
  billing_alert_threshold_usd = var.billing_alert_threshold_usd
  enable_billing_budget       = var.enable_billing_budget

  depends_on = [
    google_project_service.apis,
    module.cloud_run,
  ]
}

# Cloud Scheduler: publicacion programada de contenido (cada minuto)
resource "google_cloud_scheduler_job" "publish_scheduled_content" {
  name      = "dp-proj-00-03-publish-scheduled"
  schedule  = "* * * * *"
  time_zone = "UTC"
  region    = var.gcp_region

  http_target {
    uri         = "${module.cloud_run.service_url}/api/internal/publish-scheduled"
    http_method = "POST"

    oidc_token {
      service_account_email = module.cloud_run.service_account_email
    }

    headers = {
      "Content-Type" = "application/json"
    }
  }

  retry_config {
    retry_count = 3
  }

  depends_on = [
    google_project_service.apis,
    module.cloud_run,
  ]
}
