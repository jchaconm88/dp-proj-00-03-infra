variable "gcp_project_id" {
  description = "ID del proyecto GCP"
  type        = string
}

variable "database_url" {
  description = "Connection string de la base de datos"
  type        = string
  sensitive   = true
}

variable "neon_api_key" {
  description = "API key de Neon"
  type        = string
  sensitive   = true
}
