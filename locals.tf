locals {
  firebase_project_id = coalesce(var.firebase_project_id, var.gcp_project_id)
  neon_project_name   = coalesce(var.neon_project_name, "dp-proj-00-03-${var.suffix}")
}
