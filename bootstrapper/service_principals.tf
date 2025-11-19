# Azure Service Principals for Spacelift
# Each environment gets its own service principal with appropriate RBAC

resource "random_uuid" "sp_role_assignment" {
  for_each = var.create_service_principals ? var.service_principal_names : {}
}

# Create Azure AD Applications (Service Principals)
resource "azuread_application" "spacelift" {
  for_each = var.create_service_principals ? var.service_principal_names : {}

  display_name = each.value
  owners       = [data.azuread_client_config.current.object_id]

  tags = [
    "spacelift",
    "landing-zone-factory",
    each.key
  ]
}

resource "azuread_service_principal" "spacelift" {
  for_each = var.create_service_principals ? var.service_principal_names : {}

  client_id                    = azuread_application.spacelift[each.key].client_id
  app_role_assignment_required = false
  owners                       = [data.azuread_client_config.current.object_id]

  tags = [
    "spacelift",
    "landing-zone-factory",
    each.key
  ]
}

# Create client secrets for service principals
resource "azuread_application_password" "spacelift" {
  for_each = var.create_service_principals ? var.service_principal_names : {}

  application_id = azuread_application.spacelift[each.key].id
  display_name   = "Spacelift ${each.key}"

  end_date_relative = "8760h" # 1 year
}

# Assign Contributor role at subscription level
# In production, you should scope these more tightly
resource "azurerm_role_assignment" "spacelift_contributor" {
  for_each = var.create_service_principals ? var.service_principal_names : {}

  scope                = "/subscriptions/${var.azure_subscription_id}"
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.spacelift[each.key].object_id

  skip_service_principal_aad_check = true
}

# Locals for service principal outputs
locals {
  service_principals = {
    for key, sp in azuread_service_principal.spacelift :
    key => {
      client_id     = sp.client_id
      object_id     = sp.object_id
      client_secret = azuread_application_password.spacelift[key].value
    }
  }
}
