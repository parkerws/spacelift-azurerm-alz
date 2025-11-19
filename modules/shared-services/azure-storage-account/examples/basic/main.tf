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
  name     = "rg-storage-basic-example"
  location = "eastus"
}

module "storage" {
  source = "../.."

  name                     = "stbasicex001"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  containers = {
    "logs" = {
      container_access_type = "private"
    }
    "data" = {
      container_access_type = "private"
    }
  }

  tags = {
    Environment = "Development"
    ManagedBy   = "Terraform"
  }
}
