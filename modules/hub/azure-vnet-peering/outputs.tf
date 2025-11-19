output "id" {
  description = "The ID of the virtual network peering."
  value       = azurerm_virtual_network_peering.this.id
}

output "name" {
  description = "The name of the virtual network peering."
  value       = azurerm_virtual_network_peering.this.name
}

output "resource_group_name" {
  description = "The name of the resource group in which the virtual network peering exists."
  value       = azurerm_virtual_network_peering.this.resource_group_name
}

output "virtual_network_name" {
  description = "The name of the local virtual network."
  value       = azurerm_virtual_network_peering.this.virtual_network_name
}

output "remote_virtual_network_id" {
  description = "The ID of the remote virtual network."
  value       = azurerm_virtual_network_peering.this.remote_virtual_network_id
}

output "allow_virtual_network_access" {
  description = "Whether virtual network access is allowed."
  value       = azurerm_virtual_network_peering.this.allow_virtual_network_access
}

output "allow_forwarded_traffic" {
  description = "Whether forwarded traffic is allowed."
  value       = azurerm_virtual_network_peering.this.allow_forwarded_traffic
}

output "allow_gateway_transit" {
  description = "Whether gateway transit is allowed."
  value       = azurerm_virtual_network_peering.this.allow_gateway_transit
}

output "use_remote_gateways" {
  description = "Whether remote gateways are used."
  value       = azurerm_virtual_network_peering.this.use_remote_gateways
}

output "this" {
  description = "The full virtual network peering resource object. Use this output for accessing attributes not explicitly exposed."
  value       = azurerm_virtual_network_peering.this
}
