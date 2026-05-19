# DATABASE_URL para el CMS
resource "google_secret_manager_secret" "database_url" {
  secret_id = "dp-proj-00-03-database-url"
  project   = var.gcp_project_id

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "database_url" {
  secret      = google_secret_manager_secret.database_url.id
  secret_data = var.database_url
}

# PAYLOAD_SECRET_KEY: clave de firma de tokens Payload CMS
resource "google_secret_manager_secret" "payload_secret_key" {
  secret_id = "dp-proj-00-03-payload-secret-key"
  project   = var.gcp_project_id

  replication {
    auto {}
  }
}

resource "random_password" "payload_secret" {
  length  = 64
  special = true
}

resource "google_secret_manager_secret_version" "payload_secret_key" {
  secret      = google_secret_manager_secret.payload_secret_key.id
  secret_data = random_password.payload_secret.result
}

# INTERNAL_API_TOKEN: token para endpoint interno de publicacion programada
resource "google_secret_manager_secret" "internal_api_token" {
  secret_id = "dp-proj-00-03-internal-api-token"
  project   = var.gcp_project_id

  replication {
    auto {}
  }
}

resource "random_password" "internal_token" {
  length  = 48
  special = false
}

resource "google_secret_manager_secret_version" "internal_api_token" {
  secret      = google_secret_manager_secret.internal_api_token.id
  secret_data = random_password.internal_token.result
}

# RESEND_API_KEY: para envio de emails (placeholder, se actualiza manualmente)
resource "google_secret_manager_secret" "resend_api_key" {
  secret_id = "dp-proj-00-03-resend-api-key"
  project   = var.gcp_project_id

  replication {
    auto {}
  }
}

# TURNSTILE_SECRET_KEY: para CAPTCHA (placeholder, se actualiza manualmente)
resource "google_secret_manager_secret" "turnstile_secret_key" {
  secret_id = "dp-proj-00-03-turnstile-secret-key"
  project   = var.gcp_project_id

  replication {
    auto {}
  }
}

resource "random_password" "placeholder" {
  length  = 16
  special = false
}

resource "google_secret_manager_secret_version" "resend_api_key_placeholder" {
  secret      = google_secret_manager_secret.resend_api_key.id
  secret_data = "REPLACE_WITH_RESEND_API_KEY"
}

resource "google_secret_manager_secret_version" "turnstile_secret_key_placeholder" {
  secret      = google_secret_manager_secret.turnstile_secret_key.id
  secret_data = "REPLACE_WITH_TURNSTILE_SECRET_KEY"
}

resource "random_password" "placeholder_resend" {
  length  = 16
  special = false
}
