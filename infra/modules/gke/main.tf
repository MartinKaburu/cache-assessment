resource "google_container_cluster" "gke" {
  name     = var.cluster_name
  location = var.region
  network  = var.network
  subnetwork = var.subnetwork

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  remove_default_node_pool = true
  initial_node_count       = 1
}

resource "google_container_node_pool" "primary_nodes" {
  name       = "primary-node-pool"
  cluster    = google_container_cluster.gke.name
  location   = var.region
  node_count = var.node_count

  node_config {
    machine_type = "e2-small"
    disk_size_gb = 50     
    disk_type    = "pd-ssd" 
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }

  depends_on = [google_container_cluster.gke]
}
