variable "gcp_project_id" {
  description = "ID del proyecto GCP del bloque"
  type        = string
}

variable "cms_runtime_service_account_email" {
  description = "Service account que ejecuta el CMS en Cloud Run (impersonacion en deploy)"
  type        = string
}

variable "front_runtime_service_account_email" {
  description = "Service account que ejecuta el frontend en Cloud Run (impersonacion en deploy)"
  type        = string
}
