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
  name     = "rg-rbac-example"
  location = "eastus"
}

# Assign Reader role at resource group scope
module "rbac_reader" {
  source = "../.."

  scope                = azurerm_resource_group.example.id
  role_definition_name = "Reader"
  principal_id         = data.azurerm_client_config.current.object_id
  principal_type       = "ServicePrincipal"
  description          = "Reader access to example resource group"
}
