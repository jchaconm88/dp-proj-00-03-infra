variable "gcp_project_id" {
  description = "ID del proyecto de Google Cloud Platform"
  type        = string
}

variable "gcp_region" {
  description = "Region principal de GCP para despliegue de recursos"
  type        = string
  default     = "us-central1"
}

variable "neon_api_key" {
  description = "API key de Neon para gestión de base de datos PostgreSQL"
  type        = string
  sensitive   = true
}

variable "neon_org_id" {
  description = "ID de organizacion Neon (requerido para crear proyectos)"
  type        = string
}

variable "neon_project_name" {
  description = "Nombre del proyecto en Neon (por defecto dp-proj-00-03-{suffix})"
  type        = string
  default     = null
}

variable "cms_image" {
  description = "Imagen Docker del CMS. Bootstrap: us-docker.pkg.dev/cloudrun/container/hello"
  type        = string
  default     = "us-docker.pkg.dev/cloudrun/container/hello"
}

variable "cms_container_port" {
  description = "Puerto del contenedor Cloud Run (8080 con imagen hello de bootstrap)"
  type        = number
  default     = 8080
}

variable "cms_health_check_path" {
  description = "Ruta del health check (/ con hello, /api/health con CMS real)"
  type        = string
  default     = "/"
}

variable "cms_min_instances" {
  description = "Instancias mínimas de Cloud Run (0 para escalado a cero)"
  type        = number
  default     = 0
}

variable "cms_max_instances" {
  description = "Instancias máximas de Cloud Run"
  type        = number
  default     = 10
}

variable "front_image" {
  description = "Imagen Docker del frontend Astro. Bootstrap: us-docker.pkg.dev/cloudrun/container/hello"
  type        = string
  default     = "us-docker.pkg.dev/cloudrun/container/hello"
}

variable "front_container_port" {
  description = "Puerto del contenedor frontend (8080 con hello o Astro en prod)"
  type        = number
  default     = 8080
}

variable "front_health_check_path" {
  description = "Health check del front (/ con hello, /api/health con Astro)"
  type        = string
  default     = "/"
}

variable "front_min_instances" {
  type    = number
  default = 0
}

variable "front_max_instances" {
  type    = number
  default = 10
}

variable "billing_alert_threshold_usd" {
  description = "Umbral de alerta de gasto mensual en USD"
  type        = number
  default     = 50
}

variable "enable_billing_budget" {
  description = "Crear alerta de presupuesto GCP (requiere quota project en ADC o CI con SA)"
  type        = bool
  default     = false
}

variable "alert_email" {
  description = "Email para recibir alertas de sistema y billing"
  type        = string
}

variable "suffix" {
  description = "Sufijo de 4 hex del bloque de clientes (proyecto dp-proj-00-03-{suffix})"
  type        = string

  validation {
    condition     = can(regex("^[a-f0-9]{4}$", var.suffix))
    error_message = "El sufijo debe ser exactamente 4 caracteres hex en minusculas (ej. a1b2)."
  }
}

variable "firebase_project_id" {
  description = "ID del proyecto Firebase (por defecto igual a gcp_project_id)"
  type        = string
  default     = null
}

variable "storage_location" {
  description = "Ubicación del bucket de Firebase Storage"
  type        = string
  default     = "US"
}

variable "enable_publish_scheduler" {
  description = "Job Cloud Scheduler para publicar contenido programado (desactivar si no se usa)"
  type        = bool
  default     = false
}

variable "publish_scheduled_cron" {
  description = "Cron de publicación programada. Default cada 5 min (tolerancia requisito <= 5 min)"
  type        = string
  default     = "*/5 * * * *"
}
