output "bastion_id" {
  description = "The ID of the Bastion Host"
  value       = module.bastion.id
}

output "bastion_name" {
  description = "The name of the Bastion Host"
  value       = module.bastion.name
}

output "bastion_dns_name" {
  description = "The FQDN of the Bastion Host"
  value       = module.bastion.dns_name
}

output "bastion_public_ip" {
  description = "The public IP of the Bastion Host"
  value       = module.bastion.public_ip_address
}
