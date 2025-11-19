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
  name     = "rg-subnet-basic-example"
  location = "eastus"

  tags = {
    Environment = "Development"
    Purpose     = "Subnet Module Basic Example"
  }
}

# Create a virtual network
resource "azurerm_virtual_network" "example" {
  name                = "vnet-example-eastus-001"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  address_space       = ["10.0.0.0/16"]

  tags = {
    Environment = "Development"
    ManagedBy   = "Terraform"
  }
}

# Basic subnet with minimal configuration
module "subnet" {
  source = "../.."

  name                 = "snet-workload-001"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}
