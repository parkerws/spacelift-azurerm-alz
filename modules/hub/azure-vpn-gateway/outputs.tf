output "id" {
  description = "The ID of the Virtual Network Gateway."
  value       = azurerm_virtual_network_gateway.this.id
}

output "name" {
  description = "The name of the Virtual Network Gateway."
  value       = azurerm_virtual_network_gateway.this.name
}

output "resource_group_name" {
  description = "The name of the resource group in which the Virtual Network Gateway exists."
  value       = azurerm_virtual_network_gateway.this.resource_group_name
}

output "location" {
  description = "The location/region where the Virtual Network Gateway exists."
  value       = azurerm_virtual_network_gateway.this.location
}

output "type" {
  description = "The type of the Virtual Network Gateway."
  value       = azurerm_virtual_network_gateway.this.type
}

output "vpn_type" {
  description = "The VPN type of the Virtual Network Gateway."
  value       = azurerm_virtual_network_gateway.this.vpn_type
}

output "sku" {
  description = "The SKU of the Virtual Network Gateway."
  value       = azurerm_virtual_network_gateway.this.sku
}

output "generation" {
  description = "The generation of the Virtual Network Gateway."
  value       = azurerm_virtual_network_gateway.this.generation
}

output "bgp_settings" {
  description = "BGP settings for the Virtual Network Gateway."
  value       = try(azurerm_virtual_network_gateway.this.bgp_settings[0], null)
}

output "public_ip_addresses" {
  description = "The public IP addresses associated with the Virtual Network Gateway."
  value       = var.create_public_ips ? azurerm_public_ip.gateway[*].ip_address : []
}

output "public_ip_ids" {
  description = "The IDs of the public IP addresses associated with the Virtual Network Gateway."
  value       = local.public_ip_ids
}

output "ip_configurations" {
  description = "The IP configurations of the Virtual Network Gateway."
  value       = azurerm_virtual_network_gateway.this.ip_configuration
}

output "active_active" {
  description = "Whether the Virtual Network Gateway is in active-active mode."
  value       = azurerm_virtual_network_gateway.this.active_active
}

output "enable_bgp" {
  description = "Whether BGP is enabled on the Virtual Network Gateway."
  value       = azurerm_virtual_network_gateway.this.enable_bgp
}

output "vpn_client_configuration" {
  description = "The VPN client configuration of the Virtual Network Gateway."
  value       = try(azurerm_virtual_network_gateway.this.vpn_client_configuration[0], null)
}

output "this" {
  description = "The full Virtual Network Gateway resource object. Use this output for accessing attributes not explicitly exposed."
  value       = azurerm_virtual_network_gateway.this
}
