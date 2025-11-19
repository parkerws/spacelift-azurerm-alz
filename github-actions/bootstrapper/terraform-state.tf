# Azure Storage Account for Terraform State
# Shared across all environments with container-level separation

resource "azurerm_resource_group" "tfstate" {
  count = var.create_terraform_state_storage ? 1 : 0

  name     = "rg-tfstate-${var.github_repository}"
  location = var.state_storage_location
  tags     = var.tags
}

resource "azurerm_storage_account" "tfstate" {
  count = var.create_terraform_state_storage ? 1 : 0

  name                     = lower(replace("st${var.github_repository}tfstate", "/[^a-z0-9]/", ""))
  resource_group_name      = azurerm_resource_group.tfstate[0].name
  location                 = azurerm_resource_group.tfstate[0].location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  # Security settings
  enable_https_traffic_only       = true
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  shared_access_key_enabled       = true # Needed for backend, but rotate regularly

  # Blob properties
  blob_properties {
    versioning_enabled = true

    delete_retention_policy {
      days = 30
    }

    container_delete_retention_policy {
      days = 7
    }
  }

  tags = var.tags
}

# Container for Terraform state
resource "azurerm_storage_container" "tfstate" {
  count = var.create_terraform_state_storage ? 1 : 0

  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.tfstate[0].name
  container_access_type = "private"
}

# Containers per environment for state isolation
resource "azurerm_storage_container" "tfstate_environments" {
  for_each = var.create_terraform_state_storage ? var.environments : {}

  name                  = "tfstate-${each.key}"
  storage_account_name  = azurerm_storage_account.tfstate[0].name
  container_access_type = "private"
}

# Lock container for state locking
resource "azurerm_storage_container" "tfstate_locks" {
  count = var.create_terraform_state_storage ? 1 : 0

  name                  = "tfstate-locks"
  storage_account_name  = azurerm_storage_account.tfstate[0].name
  container_access_type = "private"
}
