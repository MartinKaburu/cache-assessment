output "bastion_ssh_private_key" {
  value     = module.vpc.bastion_ssh_private_key
  sensitive = true
}

output "bastion_external_ip" {
  value = module.vpc.bastion_external_ip
}
