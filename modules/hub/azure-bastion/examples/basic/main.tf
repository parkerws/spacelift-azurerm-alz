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
  name     = "rg-bastion-basic-example"
  location = "eastus"

  tags = {
    Environment = "Development"
    Purpose     = "Bastion Module Basic Example"
  }
}

resource "azurerm_virtual_network" "hub" {
  name                = "vnet-hub-example"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  address_space       = ["10.0.0.0/16"]

  tags = {
    Environment = "Development"
  }
}

# AzureBastionSubnet is required name (minimum /26)
resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.0.2.0/26"]
}

# Basic Azure Bastion
module "bastion" {
  source = "../.."

  name                = "bastion-hub-example-001"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  sku       = "Basic"
  subnet_id = azurerm_subnet.bastion.id

  create_public_ip = true

  tags = {
    Environment = "Development"
    ManagedBy   = "Terraform"
    Example     = "Basic"
  }
}
