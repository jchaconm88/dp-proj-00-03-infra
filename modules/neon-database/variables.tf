variable "org_id" {
  description = "ID de organizacion Neon (Consola > Organization settings)"
  type        = string
}

variable "project_name" {
  description = "Nombre del proyecto en Neon"
  type        = string
}

variable "region" {
  description = "Region del proyecto Neon (usa regiones AWS)"
  type        = string
  default     = "aws-us-east-1"
}

variable "database_name" {
  description = "Nombre de la base de datos principal"
  type        = string
  default     = "dp_proj_00_03"
}

variable "role_name" {
  description = "Nombre del rol principal de base de datos"
  type        = string
  default     = "app_user"
}

variable "pg_version" {
  description = "Version de PostgreSQL"
  type        = number
  default     = 16
}

variable "history_retention_seconds" {
  description = "Retencion PITR en segundos. Plan Free: max 21600 (6h). Por defecto del provider: 86400 (24h)."
  type        = number
  default     = 21600
}
