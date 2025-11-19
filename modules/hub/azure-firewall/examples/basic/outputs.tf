output "firewall_id" {
  description = "The ID of the Azure Firewall"
  value       = module.firewall.id
}

output "firewall_name" {
  description = "The name of the Azure Firewall"
  value       = module.firewall.name
}

output "firewall_private_ip" {
  description = "The private IP address of the Azure Firewall"
  value       = module.firewall.private_ip_address
}

output "firewall_public_ips" {
  description = "The public IP addresses of the Azure Firewall"
  value       = module.firewall.public_ip_addresses
}
