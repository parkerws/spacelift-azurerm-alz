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
  name     = "rg-vnet-peering-basic-example"
  location = "eastus"

  tags = {
    Environment = "Development"
    Purpose     = "VNet Peering Module Basic Example"
  }
}

# VNet 1
resource "azurerm_virtual_network" "vnet1" {
  name                = "vnet-1-example"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  address_space       = ["10.0.0.0/16"]

  tags = {
    Environment = "Development"
  }
}

# VNet 2
resource "azurerm_virtual_network" "vnet2" {
  name                = "vnet-2-example"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  address_space       = ["10.1.0.0/16"]

  tags = {
    Environment = "Development"
  }
}

# Basic peering: VNet 1 to VNet 2
module "peering_1_to_2" {
  source = "../.."

  name                         = "peer-vnet1-to-vnet2"
  resource_group_name          = azurerm_resource_group.example.name
  virtual_network_name         = azurerm_virtual_network.vnet1.name
  remote_virtual_network_id    = azurerm_virtual_network.vnet2.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = false
}

# Reverse peering: VNet 2 to VNet 1
module "peering_2_to_1" {
  source = "../.."

  name                         = "peer-vnet2-to-vnet1"
  resource_group_name          = azurerm_resource_group.example.name
  virtual_network_name         = azurerm_virtual_network.vnet2.name
  remote_virtual_network_id    = azurerm_virtual_network.vnet1.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = false
}
