provider "github" {
  owner = var.github_organization
  # Configure using GITHUB_TOKEN environment variable
}

provider "azurerm" {
  features {}
  subscription_id = var.azure_subscription_id
  tenant_id       = var.azure_tenant_id
}

provider "azuread" {
  tenant_id = var.azure_tenant_id
}

# Data sources
data "azurerm_client_config" "current" {}

data "azuread_client_config" "current" {}

data "github_repository" "this" {
  full_name = "${var.github_organization}/${var.github_repository}"
}
