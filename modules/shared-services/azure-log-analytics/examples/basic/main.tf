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

resource "azurerm_resource_group" "example" {
  name     = "rg-log-analytics-basic-example"
  location = "eastus"

  tags = {
    Environment = "Development"
    Purpose     = "Log Analytics Module Basic Example"
  }
}

# Basic Log Analytics Workspace
module "log_analytics" {
  source = "../.."

  name                = "law-example-001"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  sku               = "PerGB2018"
  retention_in_days = 30

  tags = {
    Environment = "Development"
    ManagedBy   = "Terraform"
    Example     = "Basic"
  }
}
