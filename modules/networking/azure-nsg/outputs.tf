output "id" {
  description = "The ID of the network security group."
  value       = azurerm_network_security_group.this.id
}

output "name" {
  description = "The name of the network security group."
  value       = azurerm_network_security_group.this.name
}

output "resource_group_name" {
  description = "The name of the resource group in which the network security group exists."
  value       = azurerm_network_security_group.this.resource_group_name
}

output "location" {
  description = "The location/region where the network security group exists."
  value       = azurerm_network_security_group.this.location
}

output "security_rule_ids" {
  description = "Map of security rule names to their IDs."
  value       = { for k, v in azurerm_network_security_rule.this : k => v.id }
}

output "security_rules" {
  description = "The security rules configured on the network security group."
  value       = [for rule in azurerm_network_security_rule.this : rule]
}

output "this" {
  description = "The full network security group resource object. Use this output for accessing attributes not explicitly exposed."
  value       = azurerm_network_security_group.this
}
