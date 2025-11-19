output "id" {
  description = "The ID of the Role Assignment."
  value       = azurerm_role_assignment.this.id
}

output "name" {
  description = "The name (GUID) of the Role Assignment."
  value       = azurerm_role_assignment.this.name
}

output "scope" {
  description = "The scope at which the Role Assignment applies."
  value       = azurerm_role_assignment.this.scope
}

output "role_definition_name" {
  description = "The name of the Role Definition."
  value       = azurerm_role_assignment.this.role_definition_name
}

output "role_definition_id" {
  description = "The ID of the Role Definition."
  value       = azurerm_role_assignment.this.role_definition_id
}

output "principal_id" {
  description = "The ID of the Principal."
  value       = azurerm_role_assignment.this.principal_id
}

output "principal_type" {
  description = "The type of the Principal."
  value       = azurerm_role_assignment.this.principal_type
}

output "this" {
  description = "The full Role Assignment resource object."
  value       = azurerm_role_assignment.this
}
