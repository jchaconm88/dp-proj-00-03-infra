variable "seed_gcp_project_id" {
  description = "Proyecto GCP bootstrap (solo Terraform: state y factory de proyectos por sufijo)"
  type        = string
}

variable "gcp_region" {
  description = "Region para buckets de state y recursos por defecto"
  type        = string
  default     = "us-central1"
}

variable "billing_account_id" {
  description = "ID de cuenta de facturacion (formato 012345-678901-ABCDEF)"
  type        = string
}

variable "folder_id" {
  description = "Folder opcional donde crear los proyectos por sufijo"
  type        = string
  default     = null
}

variable "project_prefix" {
  description = "Prefijo de IDs de proyecto GCP"
  type        = string
  default     = "dp-proj-00-03"
}

variable "suffixes" {
  description = "Listado de sufijos (4 hex). Cada uno = un proyecto GCP + bloque de clientes aislado."
  type        = set(string)

  validation {
    condition     = length(var.suffixes) > 0
    error_message = "Debe existir al menos un sufijo en suffixes.auto.tfvars."
  }

  validation {
    condition     = alltrue([for s in var.suffixes : can(regex("^[a-f0-9]{4}$", s))])
    error_message = "Cada sufijo debe ser exactamente 4 caracteres hex en minusculas (ej. a1b2)."
  }
}
