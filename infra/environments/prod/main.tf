# --- Pub/Sub ---
module "pubsub" {
  source            = "../../modules/pubsub"
  topic_name        = "prod-cache-assessment-topic"
  subscription_name = "prod-cache-assessment-subscription"
}

# --- Cache App Service Account ---
resource "google_service_account" "gke_app" {
  account_id   = "prod-cache-gsa"
  display_name = "Service Account for prod cache app to access Pub/Sub"
}

resource "google_project_iam_member" "gke_pubsub_access" {
  project = var.project_id
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:${google_service_account.gke_app.email}"
}

resource "google_service_account_iam_member" "gke_app_workload_identity_binding" {
  service_account_id = google_service_account.gke_app.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[cache-prod/prod-cache-ksa]"
}
