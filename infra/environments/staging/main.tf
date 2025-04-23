provider "google" {
  project = var.project_id
  region  = var.region
}

# --- VPC ---
module "vpc" {
  source              = "../../modules/vpc"
  network_name        = "cache-net"
  region              = var.region
  public_subnet_cidr  = "10.10.0.0/24"
  private_subnet_cidr = "10.10.1.0/24"
}

# --- GKE Cluster in private subnet ---
module "gke" {
  source       = "../../modules/gke"
  cluster_name = "cache-assessment-cluster"
  region       = var.region
  network      = module.vpc.network
  subnetwork   = module.vpc.private_subnet
  node_count   = 4
}

# --- Cloud SQL in private network ---
module "cloudsql" {
  source        = "../../modules/cloudsql"
  instance_name = "staging-postgres"
  region        = var.region
  network       = module.vpc.network
  db_name       = "cache_db"
  db_password   = var.db_password
  db_user       = var.db_user
  env           = "staging"
}

# --- Pub/Sub ---
module "pubsub" {
  source            = "../../modules/pubsub"
  topic_name        = "cache-assessment-topic"
  subscription_name = "cache-assessment-subscription"
}

# --- Cache App Service Account ---
resource "google_service_account" "gke_app" {
  account_id   = "cache-gsa"
  display_name = "Service Account for cache app to access Pub/Sub"
}

resource "google_project_iam_member" "gke_pubsub_access" {
  project = var.project_id
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:${google_service_account.gke_app.email}"
}

resource "google_service_account_iam_member" "gke_app_workload_identity_binding" {
  service_account_id = google_service_account.gke_app.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[cache-staging/cache-ksa]"
}


# --- External Secrets Operator (ESO) Service Account ---
resource "google_service_account" "eso_gsa" {
  account_id   = "eso-gsa"
  display_name = "External Secrets Operator GCP SA"
}

resource "google_project_iam_member" "eso_secret_access" {
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.eso_gsa.email}"
}

resource "google_service_account_iam_member" "eso_workload_identity_binding" {
  service_account_id = google_service_account.eso_gsa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[external-secrets/eso-ksa]"
}
