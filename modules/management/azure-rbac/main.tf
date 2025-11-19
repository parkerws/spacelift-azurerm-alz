resource "azurerm_role_assignment" "this" {
  scope                                  = var.scope
  role_definition_name                   = var.role_definition_name
  role_definition_id                     = var.role_definition_id
  principal_id                           = var.principal_id
  principal_type                         = var.principal_type
  condition                              = var.condition
  condition_version                      = var.condition_version
  delegated_managed_identity_resource_id = var.delegated_managed_identity_resource_id
  description                            = var.description
  skip_service_principal_aad_check       = var.skip_service_principal_aad_check
}
