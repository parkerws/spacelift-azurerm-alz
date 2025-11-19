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

# Create a resource group for the example
resource "azurerm_resource_group" "example" {
  name     = "rg-route-table-basic-example"
  location = "eastus"

  tags = {
    Environment = "Development"
    Purpose     = "Route Table Module Basic Example"
  }
}

# Basic route table with common routes
module "route_table" {
  source = "../.."

  name                = "rt-workload-001"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  routes = [
    {
      name           = "default-internet"
      address_prefix = "0.0.0.0/0"
      next_hop_type  = "Internet"
    },
    {
      name           = "to-hub-network"
      address_prefix = "10.0.0.0/16"
      next_hop_type  = "VNetLocal"
    }
  ]

  tags = {
    Environment = "Development"
    ManagedBy   = "Terraform"
    Example     = "Basic"
  }
}
