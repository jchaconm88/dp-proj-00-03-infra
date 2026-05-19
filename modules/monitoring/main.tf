# Canal de notificacion por email
resource "google_monitoring_notification_channel" "email" {
  project      = var.gcp_project_id
  display_name = "dp-proj-00-03 Alertas Email"
  type         = "email"

  labels = {
    email_address = var.alert_email
  }
}

# Alerta: tasa de errores HTTP 5xx > 5% en 1 minuto en Cloud Run
resource "google_monitoring_alert_policy" "cms_error_rate" {
  project      = var.gcp_project_id
  display_name = "CMS: Tasa de errores 5xx > 5%"
  combiner     = "OR"

  conditions {
    display_name = "Tasa de errores 5xx superior al 5%"

    condition_threshold {
      filter             = "resource.type=\"cloud_run_revision\" AND resource.labels.service_name=\"${var.cloud_run_service_name}\" AND metric.type=\"run.googleapis.com/request_count\" AND metric.labels.response_code_class=\"5xx\""
      denominator_filter = "resource.type=\"cloud_run_revision\" AND resource.labels.service_name=\"${var.cloud_run_service_name}\" AND metric.type=\"run.googleapis.com/request_count\""
      duration           = "60s"
      comparison         = "COMPARISON_GT"
      threshold_value    = 0.05

      aggregations {
        alignment_period     = "60s"
        per_series_aligner   = "ALIGN_RATE"
        cross_series_reducer = "REDUCE_SUM"
      }

      denominator_aggregations {
        alignment_period     = "60s"
        per_series_aligner   = "ALIGN_RATE"
        cross_series_reducer = "REDUCE_SUM"
      }
    }
  }

  notification_channels = [google_monitoring_notification_channel.email.id]

  alert_strategy {
    auto_close = "1800s" # 30 minutos
  }
}

# Alerta: servicio no disponible > 2 minutos consecutivos
resource "google_monitoring_alert_policy" "cms_unavailable" {
  project      = var.gcp_project_id
  display_name = "CMS: Servicio no disponible > 2 minutos"
  combiner     = "OR"

  conditions {
    display_name = "Health check fallando > 2 minutos"

    condition_threshold {
      filter          = "resource.type=\"cloud_run_revision\" AND resource.labels.service_name=\"${var.cloud_run_service_name}\" AND metric.type=\"run.googleapis.com/request_count\" AND metric.labels.response_code_class=\"2xx\""
      duration        = "120s"
      comparison      = "COMPARISON_LT"
      threshold_value = 1

      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_RATE"
      }
    }
  }

  notification_channels = [google_monitoring_notification_channel.email.id]
}

# Alerta: fallo de conexion a base de datos (via log-based metric)
resource "google_logging_metric" "db_connection_failure" {
  project = var.gcp_project_id
  name    = "dp_proj_00_03_db_connection_failure"
  filter  = "resource.type=\"cloud_run_revision\" AND jsonPayload.severity=\"CRITICAL\" AND jsonPayload.event=\"db_connection_failure\""

  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
    unit        = "1"
    display_name = "DB Connection Failures"
  }
}

resource "google_monitoring_alert_policy" "db_connection_failure" {
  project      = var.gcp_project_id
  display_name = "CMS: Fallo de conexion a base de datos"
  combiner     = "OR"

  conditions {
    display_name = "Fallo de conexion a BD detectado"

    condition_threshold {
      filter          = "resource.type=\"cloud_run_revision\" AND resource.labels.service_name=\"${var.cloud_run_service_name}\" AND metric.type=\"logging.googleapis.com/user/${google_logging_metric.db_connection_failure.name}\""
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0

      aggregations {
        alignment_period     = "60s"
        per_series_aligner   = "ALIGN_DELTA"
        cross_series_reducer = "REDUCE_SUM"
      }
    }
  }

  notification_channels = [google_monitoring_notification_channel.email.id]
}

# Budget / Alerta de billing (opcional: requiere quota project en ADC local o SA en CI)
resource "google_billing_budget" "main" {
  count = var.enable_billing_budget ? 1 : 0

  billing_account = data.google_project.main.billing_account
  display_name    = "dp-proj-00-03-${var.gcp_project_id}-budget"

  budget_filter {
    projects = ["projects/${data.google_project.main.number}"]
  }

  amount {
    specified_amount {
      currency_code = "USD"
      units         = tostring(var.billing_alert_threshold_usd)
    }
  }

  threshold_rules {
    threshold_percent = 0.8
    spend_basis       = "CURRENT_SPEND"
  }

  threshold_rules {
    threshold_percent = 1.0
    spend_basis       = "CURRENT_SPEND"
  }

  all_updates_rule {
    monitoring_notification_channels = [google_monitoring_notification_channel.email.id]
    disable_default_iam_recipients   = false
  }
}

data "google_project" "main" {
  project_id = var.gcp_project_id
}

# Log sink para logs estructurados del CMS
resource "google_logging_project_sink" "cms_logs" {
  project     = var.gcp_project_id
  name        = "dp-proj-00-03-cms-logs"
  destination = "logging.googleapis.com/projects/${var.gcp_project_id}/locations/global/buckets/_Default"
  filter      = "resource.type=\"cloud_run_revision\" AND resource.labels.service_name=\"${var.cloud_run_service_name}\""

  unique_writer_identity = true
}
