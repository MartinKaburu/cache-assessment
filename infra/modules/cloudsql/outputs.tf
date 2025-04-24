output "instance_connection_name" {
  value = google_sql_database_instance.postgres.connection_name
}

output "staging_db_internal_connection_string" {
  description = "Staging Internal connection string for PostgreSQL using private IP"
  value       = "postgresql://${var.staging_db_user}:${random_password.staging_db_password.result}@${google_sql_database_instance.postgres.private_ip_address}:5432/${google_sql_database.staging_db.name}"
  sensitive   = true
}

output "prod_db_internal_connection_string" {
  description = "Prod Internal connection string for PostgreSQL using private IP"
  value       = "postgresql://${var.prod_db_user}:${random_password.prod_db_password.result}@${google_sql_database_instance.postgres.private_ip_address}:5432/${google_sql_database.prod_db.name}"
  sensitive   = true
}
