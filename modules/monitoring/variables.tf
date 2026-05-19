variable "gcp_project_id" {
  description = "ID del proyecto GCP"
  type        = string
}

variable "cloud_run_service_name" {
  description = "Nombre del servicio Cloud Run del CMS"
  type        = string
}

variable "alert_email" {
  description = "Email para notificaciones de alerta"
  type        = string
}

variable "billing_alert_threshold_usd" {
  description = "Umbral de gasto mensual en USD para alerta de billing"
  type        = number
  default     = 50
}

variable "enable_billing_budget" {
  description = "Crear presupuesto de billing (false en bootstrap local sin quota project en ADC)"
  type        = bool
  default     = false
}
