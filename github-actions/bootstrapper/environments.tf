# GitHub Environments
# Environments provide deployment protection, secrets scoping, and approval gates

resource "github_repository_environment" "environments" {
  for_each = var.environments

  repository  = data.github_repository.this.name
  environment = each.key

  # Wait timer before deployment can proceed
  wait_timer = each.value.wait_timer

  # Required reviewers for deployments
  dynamic "reviewers" {
    for_each = length(each.value.reviewers) > 0 ? [1] : []
    content {
      users = each.value.reviewers
    }
  }

  # Deployment branch policy
  dynamic "deployment_branch_policy" {
    for_each = each.value.deployment_branch_policy != "all" ? [1] : []
    content {
      protected_branches     = each.value.deployment_branch_policy == "protected"
      custom_branch_policies = each.value.deployment_branch_policy == "custom"
    }
  }
}

# Environment Secrets for Azure Authentication
resource "github_actions_environment_secret" "azure_client_id" {
  for_each = var.create_service_principals ? var.environments : {}

  repository      = data.github_repository.this.name
  environment     = github_repository_environment.environments[each.key].environment
  secret_name     = "AZURE_CLIENT_ID"
  plaintext_value = azuread_application.github_actions[each.key].client_id
}

resource "github_actions_environment_secret" "azure_tenant_id" {
  for_each = var.environments

  repository      = data.github_repository.this.name
  environment     = github_repository_environment.environments[each.key].environment
  secret_name     = "AZURE_TENANT_ID"
  plaintext_value = var.azure_tenant_id
}

resource "github_actions_environment_secret" "azure_subscription_id" {
  for_each = var.environments

  repository      = data.github_repository.this.name
  environment     = github_repository_environment.environments[each.key].environment
  secret_name     = "AZURE_SUBSCRIPTION_ID"
  plaintext_value = var.azure_subscription_id
}

# Client Secret (only if not using OIDC)
resource "github_actions_environment_secret" "azure_client_secret" {
  for_each = !var.use_oidc && var.create_service_principals ? var.environments : {}

  repository      = data.github_repository.this.name
  environment     = github_repository_environment.environments[each.key].environment
  secret_name     = "AZURE_CLIENT_SECRET"
  plaintext_value = azuread_application_password.github_actions[each.key].value
}

# Repository-level secrets (shared across environments)
resource "github_actions_secret" "terraform_state_resource_group" {
  repository      = data.github_repository.this.name
  secret_name     = "TERRAFORM_STATE_RESOURCE_GROUP"
  plaintext_value = var.create_terraform_state_storage ? azurerm_resource_group.tfstate[0].name : ""
}

resource "github_actions_secret" "terraform_state_storage_account" {
  repository      = data.github_repository.this.name
  secret_name     = "TERRAFORM_STATE_STORAGE_ACCOUNT"
  plaintext_value = var.create_terraform_state_storage ? azurerm_storage_account.tfstate[0].name : ""
}

resource "github_actions_secret" "terraform_state_container" {
  repository      = data.github_repository.this.name
  secret_name     = "TERRAFORM_STATE_CONTAINER"
  plaintext_value = var.create_terraform_state_storage ? azurerm_storage_container.tfstate[0].name : ""
}

# Environment Variables (non-sensitive)
resource "github_actions_environment_variable" "azure_location" {
  for_each = var.environments

  repository    = data.github_repository.this.name
  environment   = github_repository_environment.environments[each.key].environment
  variable_name = "AZURE_LOCATION"
  value         = var.state_storage_location
}

resource "github_actions_environment_variable" "environment_name" {
  for_each = var.environments

  repository    = data.github_repository.this.name
  environment   = github_repository_environment.environments[each.key].environment
  variable_name = "ENVIRONMENT"
  value         = each.key
}
