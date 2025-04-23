output "instance_connection_name" {
  value = google_sql_database_instance.postgres.connection_name
}

output "db_internal_connection_string" {
  description = "Internal connection string for PostgreSQL using private IP"
  value       = "postgresql://${var.db_user}:${var.db_password}@${google_sql_database_instance.postgres.private_ip_address}:5432/${google_sql_database.db.name}"
  sensitive   = true
}
