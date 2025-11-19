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

# Built-in policy: Allowed locations
data "azurerm_policy_definition" "allowed_locations" {
  display_name = "Allowed locations"
}

module "policy_assignment" {
  source = "../.."

  name                 = "allowed-locations"
  display_name         = "Allowed locations for resources"
  description          = "This policy restricts the locations where resources can be deployed"
  policy_definition_id = data.azurerm_policy_definition.allowed_locations.id
  scope                = data.azurerm_subscription.current.id

  parameters = jsonencode({
    listOfAllowedLocations = {
      value = ["eastus", "westus2", "centralus"]
    }
  })

  non_compliance_messages = [
    {
      content = "Resources must be deployed in approved locations: East US, West US 2, or Central US."
    }
  ]
}
