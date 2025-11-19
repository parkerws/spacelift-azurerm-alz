provider "azurerm" {
  features {}
  subscription_id = var.azure_subscription_id
  tenant_id       = var.azure_tenant_id
}

provider "azuread" {
  tenant_id = var.azure_tenant_id
}

provider "spacelift" {
  # Configure using environment variables:
  # SPACELIFT_API_KEY_ENDPOINT
  # SPACELIFT_API_KEY_ID
  # SPACELIFT_API_KEY_SECRET
}

# Data sources
data "azurerm_client_config" "current" {}

data "azuread_client_config" "current" {}

data "spacelift_current_account" "this" {}
