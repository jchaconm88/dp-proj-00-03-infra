output "notification_channel_id" {
  description = "ID del canal de notificacion por email"
  value       = google_monitoring_notification_channel.email.id
}
