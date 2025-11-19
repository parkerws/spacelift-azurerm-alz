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
  name     = "rg-vpn-gateway-basic-example"
  location = "eastus"

  tags = {
    Environment = "Development"
    Purpose     = "VPN Gateway Module Basic Example"
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

# GatewaySubnet is required name (minimum /27, recommended /26)
resource "azurerm_subnet" "gateway" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.0.1.0/27"]
}

# Basic VPN Gateway
module "vpn_gateway" {
  source = "../.."

  name                = "vng-hub-example-001"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  type       = "Vpn"
  vpn_type   = "RouteBased"
  sku        = "VpnGw1"
  generation = "Generation2"

  subnet_id        = azurerm_subnet.gateway.id
  create_public_ips = true

  tags = {
    Environment = "Development"
    ManagedBy   = "Terraform"
    Example     = "Basic"
  }
}
