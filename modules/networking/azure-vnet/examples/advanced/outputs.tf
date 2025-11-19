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

output "vnet_dns_servers" {
  description = "The DNS servers configured for the virtual network"
  value       = module.vnet.dns_servers
}

output "vnet_bgp_community" {
  description = "The BGP community of the virtual network"
  value       = module.vnet.bgp_community
}

output "ddos_protection_plan_id" {
  description = "The ID of the DDoS protection plan"
  value       = azurerm_network_ddos_protection_plan.example.id
}
