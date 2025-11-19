terraform {
  required_version = ">= 1.8.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0.0, < 5.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

data "azurerm_subscription" "current" {}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "example" {
  name     = "rg-rbac-advanced-example"
  location = "eastus"
}

resource "azurerm_storage_account" "example" {
  name                     = "strbacexample001"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_user_assigned_identity" "example" {
  name                = "id-rbac-example"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
}

# Subscription-level Contributor role
module "rbac_subscription_contributor" {
  source = "../.."

  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Contributor"
  principal_id         = data.azurerm_client_config.current.object_id
  principal_type       = "ServicePrincipal"
  description          = "Subscription-level contributor access"
}

# Resource group-level Owner role
module "rbac_rg_owner" {
  source = "../.."

  scope                = azurerm_resource_group.example.id
  role_definition_name = "Owner"
  principal_id         = data.azurerm_client_config.current.object_id
  principal_type       = "ServicePrincipal"
  description          = "Resource group owner for management"
}

# Storage account-level role
module "rbac_storage_blob_contributor" {
  source = "../.."

  scope                = azurerm_storage_account.example.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.example.principal_id
  principal_type       = "ServicePrincipal"
  description          = "Managed identity access to storage blobs"

  # Skip AAD check for newly created managed identity
  skip_service_principal_aad_check = true
}

# Conditional role assignment with ABAC
module "rbac_conditional_blob_reader" {
  source = "../.."

  scope                = azurerm_storage_account.example.id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = azurerm_user_assigned_identity.example.principal_id
  principal_type       = "ServicePrincipal"

  # Condition: Only allow reading blobs in containers with "public" in the name
  condition = <<-EOT
    (
      (
        !(ActionMatches{'Microsoft.Storage/storageAccounts/blobServices/containers/blobs/read'})
      )
      OR
      (
        @Resource[Microsoft.Storage/storageAccounts/blobServices/containers:name] StringLike 'public*'
      )
    )
  EOT

  condition_version = "2.0"
  description       = "Conditional blob read access to public containers only"

  skip_service_principal_aad_check = true
}

# Custom role definition and assignment
resource "azurerm_role_definition" "vm_operator" {
  name  = "Custom VM Operator"
  scope = data.azurerm_subscription.current.id

  description = "Can start, stop, and restart virtual machines"

  permissions {
    actions = [
      "Microsoft.Compute/virtualMachines/read",
      "Microsoft.Compute/virtualMachines/start/action",
      "Microsoft.Compute/virtualMachines/restart/action",
      "Microsoft.Compute/virtualMachines/powerOff/action",
      "Microsoft.Compute/virtualMachines/deallocate/action"
    ]
    not_actions = []
  }

  assignable_scopes = [
    data.azurerm_subscription.current.id
  ]
}

module "rbac_custom_vm_operator" {
  source = "../.."

  scope              = azurerm_resource_group.example.id
  role_definition_id = azurerm_role_definition.vm_operator.role_definition_resource_id
  principal_id       = azurerm_user_assigned_identity.example.principal_id
  principal_type     = "ServicePrincipal"
  description        = "Custom VM operator role for automation"

  skip_service_principal_aad_check = true
}

# Network Contributor role at resource group
module "rbac_network_contributor" {
  source = "../.."

  scope                = azurerm_resource_group.example.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.example.principal_id
  principal_type       = "ServicePrincipal"
  description          = "Network management permissions"

  skip_service_principal_aad_check = true
}
