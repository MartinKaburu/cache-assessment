output "public_subnet" {
  value = google_compute_subnetwork.public_subnet.self_link
}

output "private_subnet" {
  value = google_compute_subnetwork.private_subnet.self_link
}

output "network" {
  value = google_compute_network.vpc.self_link
}