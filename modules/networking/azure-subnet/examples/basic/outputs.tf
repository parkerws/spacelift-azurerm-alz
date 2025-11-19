output "subnet_id" {
  description = "The ID of the subnet"
  value       = module.subnet.id
}

output "subnet_name" {
  description = "The name of the subnet"
  value       = module.subnet.name
}

output "subnet_address_prefixes" {
  description = "The address prefixes of the subnet"
  value       = module.subnet.address_prefixes
}
