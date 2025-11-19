output "vnet_id" {
  description = "The ID of the virtual network"
  value       = module.vnet.id
}

output "vnet_name" {
  description = "The name of the virtual network"
  value       = module.vnet.name
}

output "vnet_address_space" {
  description = "The address space of the virtual network"
  value       = module.vnet.address_space
}

output "vnet_guid" {
  description = "The GUID of the virtual network"
  value       = module.vnet.guid
}
