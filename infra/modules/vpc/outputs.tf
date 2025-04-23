output "public_subnet" {
  value = google_compute_subnetwork.public_subnet.self_link
}

output "private_subnet" {
  value = google_compute_subnetwork.private_subnet.self_link
}

output "network" {
  value = google_compute_network.vpc.self_link
}

output "bastion_ssh_private_key" {
  value     = tls_private_key.bastion_key.private_key_pem
  sensitive = true
}

output "bastion_external_ip" {
  value = google_compute_instance.bastion.network_interface[0].access_config[0].nat_ip
}
