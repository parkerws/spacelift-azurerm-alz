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
  name     = "rg-acr-basic-example"
  location = "eastus"
}

module "acr" {
  source = "../.."

  name                = "acrbasicexample001"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  sku                 = "Standard"

  tags = {
    Environment = "Development"
    ManagedBy   = "Terraform"
  }
}
