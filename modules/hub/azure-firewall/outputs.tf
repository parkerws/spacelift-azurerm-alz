output "id" {
  description = "The ID of the Azure Firewall."
  value       = azurerm_firewall.this.id
}

output "name" {
  description = "The name of the Azure Firewall."
  value       = azurerm_firewall.this.name
}

output "resource_group_name" {
  description = "The name of the resource group in which the Azure Firewall exists."
  value       = azurerm_firewall.this.resource_group_name
}

output "location" {
  description = "The location/region where the Azure Firewall exists."
  value       = azurerm_firewall.this.location
}

output "private_ip_address" {
  description = "The private IP address of the Azure Firewall."
  value       = azurerm_firewall.this.ip_configuration[0].private_ip_address
}

output "public_ip_addresses" {
  description = "The public IP addresses associated with the Azure Firewall."
  value       = local.create_public_ips ? azurerm_public_ip.firewall[*].ip_address : []
}

output "public_ip_ids" {
  description = "The IDs of the public IP addresses associated with the Azure Firewall."
  value       = local.create_public_ips ? azurerm_public_ip.firewall[*].id : []
}

output "ip_configurations" {
  description = "The IP configurations of the Azure Firewall."
  value       = azurerm_firewall.this.ip_configuration
}

output "virtual_hub_private_ip_address" {
  description = "The private IP address associated with the Azure Firewall when deployed in Virtual WAN hub."
  value       = try(azurerm_firewall.this.virtual_hub[0].private_ip_address, null)
}

output "virtual_hub_public_ip_addresses" {
  description = "The public IP addresses associated with the Azure Firewall when deployed in Virtual WAN hub."
  value       = try(azurerm_firewall.this.virtual_hub[0].public_ip_addresses, null)
}

output "threat_intel_mode" {
  description = "The threat intelligence mode of the Azure Firewall."
  value       = azurerm_firewall.this.threat_intel_mode
}

output "sku_name" {
  description = "The SKU name of the Azure Firewall."
  value       = azurerm_firewall.this.sku_name
}

output "sku_tier" {
  description = "The SKU tier of the Azure Firewall."
  value       = azurerm_firewall.this.sku_tier
}

output "zones" {
  description = "The availability zones of the Azure Firewall."
  value       = azurerm_firewall.this.zones
}

output "firewall_policy_id" {
  description = "The ID of the Firewall Policy applied to the Azure Firewall."
  value       = azurerm_firewall.this.firewall_policy_id
}

output "dns_servers" {
  description = "The DNS servers configured for the Azure Firewall."
  value       = azurerm_firewall.this.dns_servers
}

output "this" {
  description = "The full Azure Firewall resource object. Use this output for accessing attributes not explicitly exposed."
  value       = azurerm_firewall.this
}
