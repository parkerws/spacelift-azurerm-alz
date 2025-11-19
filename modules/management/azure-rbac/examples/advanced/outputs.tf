output "subscription_contributor_id" {
  description = "Subscription contributor role assignment ID"
  value       = module.rbac_subscription_contributor.id
}

output "rg_owner_id" {
  description = "Resource group owner role assignment ID"
  value       = module.rbac_rg_owner.id
}

output "storage_blob_contributor_id" {
  description = "Storage blob contributor role assignment ID"
  value       = module.rbac_storage_blob_contributor.id
}

output "conditional_blob_reader_id" {
  description = "Conditional blob reader role assignment ID"
  value       = module.rbac_conditional_blob_reader.id
}

output "custom_vm_operator_id" {
  description = "Custom VM operator role assignment ID"
  value       = module.rbac_custom_vm_operator.id
}

output "network_contributor_id" {
  description = "Network contributor role assignment ID"
  value       = module.rbac_network_contributor.id
}

output "managed_identity_principal_id" {
  description = "The principal ID of the managed identity"
  value       = azurerm_user_assigned_identity.example.principal_id
}

output "custom_role_id" {
  description = "The ID of the custom VM operator role definition"
  value       = azurerm_role_definition.vm_operator.role_definition_resource_id
}
