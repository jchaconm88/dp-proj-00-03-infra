variable "gcp_project_id" {
  description = "ID del proyecto GCP"
  type        = string
}

variable "gcp_region" {
  description = "Region de GCP"
  type        = string
}

variable "cms_image" {
  description = "Imagen Docker del CMS"
  type        = string
}

variable "container_port" {
  description = "Puerto del contenedor (8080 para imagen bootstrap hello de Cloud Run)"
  type        = number
  default     = 3000
}

variable "health_check_path" {
  description = "Ruta del health check HTTP"
  type        = string
  default     = "/api/health"
}

variable "min_instances" {
  description = "Instancias minimas (0 para escalado a cero)"
  type        = number
  default     = 0
}

variable "max_instances" {
  description = "Instancias maximas"
  type        = number
  default     = 10
}

variable "database_url_secret" {
  description = "ID del secreto de Secret Manager para DATABASE_URL"
  type        = string
}

variable "payload_secret_key_secret" {
  description = "ID del secreto de Secret Manager para PAYLOAD_SECRET_KEY"
  type        = string
}

variable "storage_bucket" {
  description = "Nombre del bucket de Firebase Storage"
  type        = string
}

variable "memory_limit" {
  description = "Limite de memoria por instancia"
  type        = string
  default     = "512Mi"
}

variable "cpu_limit" {
  description = "Limite de CPU por instancia"
  type        = string
  default     = "1"
}

variable "request_timeout" {
  description = "Timeout de peticion en segundos"
  type        = number
  default     = 30
}

variable "concurrency" {
  description = "Peticiones concurrentes por instancia"
  type        = number
  default     = 80
}
