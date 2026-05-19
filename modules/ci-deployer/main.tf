# Cuenta de servicio para GitHub Actions (deploy CMS). La clave JSON se crea manualmente.
resource "google_service_account" "github_deploy" {
  account_id   = "dp-proj-00-03-ci-deploy"
  display_name = "GitHub Actions deploy (CMS)"
  project      = var.gcp_project_id
}

resource "google_project_iam_member" "artifact_registry_writer" {
  project = var.gcp_project_id
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:${google_service_account.github_deploy.email}"
}

resource "google_project_iam_member" "run_admin" {
  project = var.gcp_project_id
  role    = "roles/run.admin"
  member  = "serviceAccount:${google_service_account.github_deploy.email}"
}

# Permite desplegar revisiones que corren como la SA de runtime del CMS
resource "google_service_account_iam_member" "act_as_cms_runtime" {
  service_account_id = "projects/${var.gcp_project_id}/serviceAccounts/${var.cms_runtime_service_account_email}"
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${google_service_account.github_deploy.email}"
}
