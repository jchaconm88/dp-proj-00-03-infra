variable "gcp_project_id" {
  description = "ID del proyecto GCP"
  type        = string
}

variable "gcp_region" {
  description = "Region de GCP"
  type        = string
}

variable "front_image" {
  description = "Imagen Docker del frontend Astro SSR"
  type        = string
}

variable "container_port" {
  description = "Puerto del contenedor (8080 en produccion)"
  type        = number
  default     = 8080
}

variable "health_check_path" {
  description = "Ruta del health check HTTP"
  type        = string
  default     = "/api/health"
}

variable "min_instances" {
  type    = number
  default = 0
}

variable "max_instances" {
  type    = number
  default = 10
}

variable "memory_limit" {
  type    = string
  default = "1Gi"
}

variable "cpu_limit" {
  type    = string
  default = "1"
}

variable "request_timeout" {
  type    = number
  default = 60
}

variable "concurrency" {
  type    = number
  default = 80
}
