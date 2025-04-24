resource "google_sql_database_instance" "postgres" {
  name             = var.instance_name
  database_version = "POSTGRES_15"
  region           = var.region

  settings {
    tier = "db-f1-micro"
    ip_configuration {
      ipv4_enabled    = false
      private_network = var.network
    }
  }

  deletion_protection = false
}

resource "google_sql_database" "staging_db" {
  name     = var.staging_db_name
  instance = google_sql_database_instance.postgres.name
}

resource "random_password" "staging_db_password" {
  length  = 16
  special = false
  upper   = true
  lower   = true
}

resource "google_sql_user" "staging_user" {
  name     = var.staging_db_user
  instance = google_sql_database_instance.postgres.name
  password = random_password.staging_db_password.result
}

resource "google_sql_database" "prod_db" {
  name     = var.prod_db_name
  instance = google_sql_database_instance.postgres.name
}

resource "random_password" "prod_db_password" {
  length  = 16
  special = false
  upper   = true
  lower   = true
}

resource "google_sql_user" "prod_user" {
  name     = var.prod_db_user
  instance = google_sql_database_instance.postgres.name
  password = random_password.prod_db_password.result
}


resource "google_secret_manager_secret" "staging_db_password" {
  secret_id = "staging-db-password"

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "staging_db_password_version" {
  secret      = google_secret_manager_secret.prod_db_password.id
  secret_data = "postgresql://${var.staging_db_user}:${random_password.staging_db_password.result}@${google_sql_database_instance.postgres.private_ip_address}:5432/${google_sql_database.staging_db.name}"
}

resource "google_secret_manager_secret" "prod_db_password" {
  secret_id = "prod-db-password"

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "prod_db_password_version" {
  secret      = google_secret_manager_secret.prod_db_password.id
  secret_data = "postgresql://${var.prod_db_user}:${random_password.prod_db_password.result}@${google_sql_database_instance.postgres.private_ip_address}:5432/${google_sql_database.prod_db.name}"
}