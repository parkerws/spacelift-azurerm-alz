output "id" {
  description = "The ID of the Management Group."
  value       = azurerm_management_group.this.id
}

output "name" {
  description = "The name of the Management Group."
  value       = azurerm_management_group.this.name
}

output "display_name" {
  description = "The display name of the Management Group."
  value       = azurerm_management_group.this.display_name
}

output "parent_management_group_id" {
  description = "The ID of the parent Management Group."
  value       = azurerm_management_group.this.parent_management_group_id
}

output "subscription_ids" {
  description = "The list of Subscription IDs associated with this Management Group."
  value       = azurerm_management_group.this.subscription_ids
}

output "this" {
  description = "The full Management Group resource object."
  value       = azurerm_management_group.this
}
