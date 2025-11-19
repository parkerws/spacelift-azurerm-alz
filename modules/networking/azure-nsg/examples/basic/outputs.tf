output "nsg_id" {
  description = "The ID of the network security group"
  value       = module.nsg.id
}

output "nsg_name" {
  description = "The name of the network security group"
  value       = module.nsg.name
}

output "security_rules" {
  description = "The security rules in the NSG"
  value       = module.nsg.security_rules
}
