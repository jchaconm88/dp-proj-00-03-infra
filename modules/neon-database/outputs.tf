output "project_id" {
  description = "ID del proyecto Neon"
  value       = neon_project.main.id
}

output "database_id" {
  description = "ID de la base de datos"
  value       = neon_database.main.id
}

output "connection_string" {
  description = "Connection string del rol app_user (runtime del CMS)"
  value       = "postgresql://${neon_role.app.name}:${neon_role.app.password}@${neon_project.main.database_host}/${neon_database.main.name}?sslmode=require"
  sensitive   = true
}

output "owner_connection_string" {
  description = "Connection string del rol owner de Neon (migraciones y DDL)"
  value       = "postgresql://${neon_project.main.database_user}:${neon_project.main.database_password}@${neon_project.main.database_host}/${neon_database.main.name}?sslmode=require"
  sensitive   = true
}

output "direct_connection_string" {
  description = "Connection string directo (sin pooler, para migraciones)"
  value       = "postgresql://${neon_role.app.name}:${neon_role.app.password}@${neon_project.main.database_host}/${neon_database.main.name}?sslmode=require&endpoint=${neon_project.main.default_branch_id}"
  sensitive   = true
}

output "host" {
  description = "Host de la base de datos"
  value       = neon_project.main.database_host
}
