variable "gcp_project_id" {
  description = "ID del proyecto GCP"
  type        = string
}

variable "firebase_project_id" {
  description = "ID del proyecto Firebase"
  type        = string
}

variable "suffix" {
  description = "Sufijo del bloque (4 hex) para IDs unicos globales"
  type        = string
}

variable "site_id" {
  description = "ID del sitio de Firebase Hosting (debe ser unico globalmente)"
  type        = string
  default     = null
}

locals {
  site_id = coalesce(var.site_id, "dp-proj-00-03-${var.suffix}-front")
}
