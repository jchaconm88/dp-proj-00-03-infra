output "suffixes" {
  description = "Sufijos registrados (mapeo activo de bloques de clientes)"
  value       = sort(tolist(var.suffixes))
}

output "block_project_ids" {
  description = "ID de proyecto GCP por sufijo (dp-proj-00-03-{suffix})"
  value       = { for suffix, p in google_project.block : suffix => p.project_id }
}

output "block_project_numbers" {
  description = "Numero de proyecto GCP por sufijo"
  value       = { for suffix, p in google_project.block : suffix => p.number }
}

output "platform_state_buckets" {
  description = "Buckets GCS de state de plataforma por sufijo (en proyecto seed)"
  value       = { for suffix, b in google_storage_bucket.platform_state : suffix => b.name }
}

output "platform_state_prefixes" {
  description = "Prefijo de state de Terraform de plataforma por sufijo"
  value       = { for suffix in var.suffixes : suffix => "platform/${suffix}" }
}
