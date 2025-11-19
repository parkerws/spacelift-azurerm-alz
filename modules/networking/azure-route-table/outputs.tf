output "id" {
  description = "The ID of the route table."
  value       = azurerm_route_table.this.id
}

output "name" {
  description = "The name of the route table."
  value       = azurerm_route_table.this.name
}

output "resource_group_name" {
  description = "The name of the resource group in which the route table exists."
  value       = azurerm_route_table.this.resource_group_name
}

output "location" {
  description = "The location/region where the route table exists."
  value       = azurerm_route_table.this.location
}

output "route_ids" {
  description = "Map of route names to their IDs."
  value       = { for k, v in azurerm_route.this : k => v.id }
}

output "routes" {
  description = "The routes configured in the route table."
  value       = [for route in azurerm_route.this : route]
}

output "subnets" {
  description = "The collection of subnets associated with this route table."
  value       = azurerm_route_table.this.subnets
}

output "disable_bgp_route_propagation" {
  description = "Whether BGP route propagation is disabled."
  value       = azurerm_route_table.this.disable_bgp_route_propagation
}

output "this" {
  description = "The full route table resource object. Use this output for accessing attributes not explicitly exposed."
  value       = azurerm_route_table.this
}
