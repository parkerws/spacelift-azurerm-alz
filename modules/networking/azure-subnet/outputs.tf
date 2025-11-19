output "id" {
  description = "The ID of the subnet."
  value       = azurerm_subnet.this.id
}

output "name" {
  description = "The name of the subnet."
  value       = azurerm_subnet.this.name
}

output "resource_group_name" {
  description = "The name of the resource group in which the subnet exists."
  value       = azurerm_subnet.this.resource_group_name
}

output "virtual_network_name" {
  description = "The name of the virtual network to which the subnet is attached."
  value       = azurerm_subnet.this.virtual_network_name
}

output "address_prefixes" {
  description = "The address prefixes for the subnet."
  value       = azurerm_subnet.this.address_prefixes
}

output "service_endpoints" {
  description = "The list of service endpoints associated with the subnet."
  value       = azurerm_subnet.this.service_endpoints
}

output "delegations" {
  description = "The list of delegations configured on the subnet."
  value       = azurerm_subnet.this.delegation
}

output "private_endpoint_network_policies" {
  description = "The network policies setting for private endpoints on the subnet."
  value       = azurerm_subnet.this.private_endpoint_network_policies
}

output "this" {
  description = "The full subnet resource object. Use this output for accessing attributes not explicitly exposed."
  value       = azurerm_subnet.this
}
