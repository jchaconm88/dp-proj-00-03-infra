variable "gcp_project_id" {
  description = "ID del proyecto GCP"
  type        = string
}

variable "storage_location" {
  description = "Ubicacion del bucket"
  type        = string
  default     = "US"
}

variable "bucket_name_suffix" {
  description = "Sufijo del nombre del bucket"
  type        = string
  default     = "storage"
}
