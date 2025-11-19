output "id" {
  description = "The ID of the virtual network."
  value       = azurerm_virtual_network.this.id
}

output "name" {
  description = "The name of the virtual network."
  value       = azurerm_virtual_network.this.name
}

output "resource_group_name" {
  description = "The name of the resource group in which the virtual network was created."
  value       = azurerm_virtual_network.this.resource_group_name
}

output "location" {
  description = "The location/region where the virtual network exists."
  value       = azurerm_virtual_network.this.location
}

output "address_space" {
  description = "The address space of the virtual network."
  value       = azurerm_virtual_network.this.address_space
}

output "guid" {
  description = "The GUID of the virtual network."
  value       = azurerm_virtual_network.this.guid
}

output "subnet_ids" {
  description = "The IDs of subnets created within this virtual network. Note: Subnets managed separately won't appear here."
  value       = [for subnet in azurerm_virtual_network.this.subnet : subnet.id]
}

output "dns_servers" {
  description = "The list of DNS servers configured for the virtual network."
  value       = azurerm_virtual_network.this.dns_servers
}

output "bgp_community" {
  description = "The BGP community attribute of the virtual network."
  value       = azurerm_virtual_network.this.bgp_community
}

output "this" {
  description = "The full virtual network resource object. Use this output for accessing attributes not explicitly exposed."
  value       = azurerm_virtual_network.this
}
