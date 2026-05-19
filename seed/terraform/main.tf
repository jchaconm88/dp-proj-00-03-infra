# Un proyecto GCP por sufijo (bloque de clientes). Agregar sufijos en suffixes.auto.tfvars
# solo crea recursos nuevos; los existentes no se modifican (for_each).
resource "google_project" "block" {
  for_each = var.suffixes

  name            = "${var.project_prefix}-${each.key}"
  project_id      = "${var.project_prefix}-${each.key}"
  billing_account = var.billing_account_id
  folder_id       = var.folder_id

  labels = {
    platform   = var.project_prefix
    suffix     = each.key
    managed_by = "terraform-seed"
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "time_sleep" "wait_for_projects" {
  depends_on      = [google_project.block]
  create_duration = "30s"
}

# State remoto de plataforma por sufijo (en proyecto seed)
resource "google_storage_bucket" "platform_state" {
  for_each = var.suffixes

  name     = "${var.project_prefix}-tfstate-${each.key}"
  project  = var.seed_gcp_project_id
  location = var.gcp_region

  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }

  labels = {
    suffix  = each.key
    purpose = "terraform-platform-state"
  }

  depends_on = [time_sleep.wait_for_projects]
}
