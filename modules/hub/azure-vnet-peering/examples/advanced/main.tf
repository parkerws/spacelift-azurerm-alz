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
  name     = "rg-vnet-peering-advanced-example"
  location = "eastus"

  tags = {
    Environment = "Production"
    Purpose     = "VNet Peering Module Advanced Example"
  }
}

# Hub VNet with VPN Gateway
resource "azurerm_virtual_network" "hub" {
  name                = "vnet-hub-prod-eastus-001"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  address_space       = ["10.0.0.0/16"]

  tags = {
    Environment = "Production"
    NetworkType = "Hub"
  }
}

# Spoke VNet 1
resource "azurerm_virtual_network" "spoke1" {
  name                = "vnet-spoke1-prod-eastus-001"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  address_space       = ["10.1.0.0/16"]

  tags = {
    Environment = "Production"
    NetworkType = "Spoke"
    Workload    = "App1"
  }
}

# Spoke VNet 2
resource "azurerm_virtual_network" "spoke2" {
  name                = "vnet-spoke2-prod-eastus-001"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  address_space       = ["10.2.0.0/16"]

  tags = {
    Environment = "Production"
    NetworkType = "Spoke"
    Workload    = "App2"
  }
}

# Hub to Spoke 1 peering (Hub side)
module "peering_hub_to_spoke1" {
  source = "../.."

  name                         = "peer-hub-to-spoke1"
  resource_group_name          = azurerm_resource_group.example.name
  virtual_network_name         = azurerm_virtual_network.hub.name
  remote_virtual_network_id    = azurerm_virtual_network.spoke1.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true  # Hub allows forwarded traffic
  allow_gateway_transit        = true  # Hub offers gateway to spoke
  use_remote_gateways          = false

  triggers = {
    spoke_address_space = join(",", azurerm_virtual_network.spoke1.address_space)
  }
}

# Spoke 1 to Hub peering (Spoke side)
module "peering_spoke1_to_hub" {
  source = "../.."

  name                         = "peer-spoke1-to-hub"
  resource_group_name          = azurerm_resource_group.example.name
  virtual_network_name         = azurerm_virtual_network.spoke1.name
  remote_virtual_network_id    = azurerm_virtual_network.hub.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true  # Allow traffic from other spokes via hub
  allow_gateway_transit        = false
  use_remote_gateways          = false  # Set to true if hub has VPN/ER gateway

  triggers = {
    hub_address_space = join(",", azurerm_virtual_network.hub.address_space)
  }
}

# Hub to Spoke 2 peering (Hub side)
module "peering_hub_to_spoke2" {
  source = "../.."

  name                         = "peer-hub-to-spoke2"
  resource_group_name          = azurerm_resource_group.example.name
  virtual_network_name         = azurerm_virtual_network.hub.name
  remote_virtual_network_id    = azurerm_virtual_network.spoke2.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  use_remote_gateways          = false

  triggers = {
    spoke_address_space = join(",", azurerm_virtual_network.spoke2.address_space)
  }
}

# Spoke 2 to Hub peering (Spoke side)
module "peering_spoke2_to_hub" {
  source = "../.."

  name                         = "peer-spoke2-to-hub"
  resource_group_name          = azurerm_resource_group.example.name
  virtual_network_name         = azurerm_virtual_network.spoke2.name
  remote_virtual_network_id    = azurerm_virtual_network.hub.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false

  triggers = {
    hub_address_space = join(",", azurerm_virtual_network.hub.address_space)
  }
}
