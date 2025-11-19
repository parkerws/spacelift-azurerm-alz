# Azure Service Principals for GitHub Actions
# One service principal per environment

resource "random_uuid" "sp_role_assignment" {
  for_each = var.create_service_principals ? var.environments : {}
}

# Azure AD Applications
resource "azuread_application" "github_actions" {
  for_each = var.create_service_principals ? var.environments : {}

  display_name = "github-actions-${var.github_repository}-${each.key}"
  owners       = [data.azuread_client_config.current.object_id]

  tags = [
    "github-actions",
    "landing-zone-factory",
    each.key
  ]
}

# Service Principals
resource "azuread_service_principal" "github_actions" {
  for_each = var.create_service_principals ? var.environments : {}

  client_id                    = azuread_application.github_actions[each.key].client_id
  app_role_assignment_required = false
  owners                       = [data.azuread_client_config.current.object_id]

  tags = [
    "github-actions",
    "landing-zone-factory",
    each.key
  ]
}

# Federated Identity Credentials for OIDC (recommended)
resource "azuread_application_federated_identity_credential" "github_environment" {
  for_each = var.use_oidc && var.create_service_principals ? var.environments : {}

  application_id = azuread_application.github_actions[each.key].id
  display_name   = "github-${each.key}"
  description    = "GitHub Actions OIDC for ${each.key} environment"
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = "https://token.actions.githubusercontent.com"
  subject        = "repo:${var.github_organization}/${var.github_repository}:environment:${each.key}"
}

# Federated Identity for branch-based deployments
resource "azuread_application_federated_identity_credential" "github_branch" {
  for_each = var.use_oidc && var.create_service_principals ? var.environments : {}

  application_id = azuread_application.github_actions[each.key].id
  display_name   = "github-${each.key}-branch"
  description    = "GitHub Actions OIDC for ${each.key} branch"
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = "https://token.actions.githubusercontent.com"
  subject        = "repo:${var.github_organization}/${var.github_repository}:ref:refs/heads/${each.key == "production" ? "main" : each.key}"
}

# Client Secrets (only if not using OIDC)
resource "azuread_application_password" "github_actions" {
  for_each = !var.use_oidc && var.create_service_principals ? var.environments : {}

  application_id = azuread_application.github_actions[each.key].id
  display_name   = "GitHub Actions ${each.key}"

  end_date_relative = "8760h" # 1 year
}

# Role Assignments
resource "azurerm_role_assignment" "github_actions_contributor" {
  for_each = var.create_service_principals ? var.environments : {}

  scope                = "/subscriptions/${var.azure_subscription_id}"
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.github_actions[each.key].object_id

  skip_service_principal_aad_check = true
}

# Additional permissions for state storage
resource "azurerm_role_assignment" "github_actions_storage" {
  for_each = var.create_service_principals && var.create_terraform_state_storage ? var.environments : {}

  scope                = azurerm_storage_account.tfstate[0].id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azuread_service_principal.github_actions[each.key].object_id

  skip_service_principal_aad_check = true
}
