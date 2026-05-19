# Proyecto Neon
resource "neon_project" "main" {
  name                      = var.project_name
  org_id                    = var.org_id
  region_id                 = var.region
  pg_version                = var.pg_version
  history_retention_seconds = var.history_retention_seconds

  branch {
    name = "main"
  }

  # default_endpoint_settings (suspend_timeout, autoscaling) no esta permitido en plan Free.
  # En planes de pago, descomentar o usar variable endpoint_settings en variables.tf.
}

# Base de datos principal
resource "neon_database" "main" {
  project_id = neon_project.main.id
  branch_id  = neon_project.main.default_branch_id
  name       = var.database_name
  owner_name = neon_project.main.database_user
}

# Rol de aplicacion
resource "neon_role" "app" {
  project_id = neon_project.main.id
  branch_id  = neon_project.main.default_branch_id
  name       = var.role_name
}

# Tablas Payload: seed/scripts/setup-database.sh (migrate + grants + RLS)
# tras terraform apply en seed/deploy-block.sh
