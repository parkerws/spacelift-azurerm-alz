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
  name     = "rg-route-table-advanced-example"
  location = "eastus"

  tags = {
    Environment = "Production"
    Purpose     = "Route Table Module Advanced Example"
  }
}

# Hub-spoke pattern: Spoke route table forcing traffic through Azure Firewall
module "route_table_spoke" {
  source = "../.."

  name                = "rt-spoke-to-hub-001"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  # Disable BGP route propagation to prevent on-premises routes from bypassing firewall
  disable_bgp_route_propagation = true

  routes = [
    {
      name                   = "default-to-firewall"
      address_prefix         = "0.0.0.0/0"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = "10.0.0.4" # Azure Firewall private IP
    },
    {
      name                   = "to-other-spoke"
      address_prefix         = "10.2.0.0/16"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = "10.0.0.4" # Azure Firewall private IP
    },
    {
      name                   = "to-on-premises"
      address_prefix         = "192.168.0.0/16"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = "10.0.0.4" # Azure Firewall private IP
    }
  ]

  tags = {
    Environment = "Production"
    NetworkType = "Spoke"
    ManagedBy   = "Terraform"
  }
}

# Gateway subnet route table (hub)
module "route_table_gateway_subnet" {
  source = "../.."

  name                = "rt-gateway-subnet-001"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  # Enable BGP route propagation for VPN/ExpressRoute
  disable_bgp_route_propagation = false

  routes = [
    {
      name                   = "spoke1-to-firewall"
      address_prefix         = "10.1.0.0/16"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = "10.0.0.4"
    },
    {
      name                   = "spoke2-to-firewall"
      address_prefix         = "10.2.0.0/16"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = "10.0.0.4"
    }
  ]

  tags = {
    Environment = "Production"
    NetworkType = "Hub"
    Purpose     = "GatewaySubnet"
    ManagedBy   = "Terraform"
  }
}

# Private endpoint subnet route table
module "route_table_private_endpoints" {
  source = "../.."

  name                = "rt-private-endpoints-001"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  # Disable BGP to ensure consistent routing
  disable_bgp_route_propagation = true

  routes = [
    {
      name           = "internet-to-firewall"
      address_prefix = "0.0.0.0/0"
      next_hop_type  = "None" # Block internet access for private endpoints
    }
  ]

  tags = {
    Environment = "Production"
    Purpose     = "PrivateEndpoints"
    ManagedBy   = "Terraform"
  }
}

# Route table for forced tunneling (send all internet traffic to on-premises)
module "route_table_forced_tunnel" {
  source = "../.."

  name                = "rt-forced-tunnel-001"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  # Disable BGP to prevent default route conflicts
  disable_bgp_route_propagation = true

  routes = [
    {
      name           = "default-to-vpn"
      address_prefix = "0.0.0.0/0"
      next_hop_type  = "VirtualNetworkGateway"
    }
  ]

  tags = {
    Environment = "Production"
    Pattern     = "ForcedTunneling"
    ManagedBy   = "Terraform"
  }
}

# Multi-region route table (using NVA in different region)
module "route_table_multi_region" {
  source = "../.."

  name                = "rt-multi-region-001"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  disable_bgp_route_propagation = false

  routes = [
    {
      name                   = "to-westus-via-nva"
      address_prefix         = "10.100.0.0/16"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = "10.0.0.10" # NVA handling cross-region traffic
    },
    {
      name                   = "to-northeurope-via-nva"
      address_prefix         = "10.200.0.0/16"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = "10.0.0.10"
    },
    {
      name           = "default-internet"
      address_prefix = "0.0.0.0/0"
      next_hop_type  = "Internet"
    }
  ]

  tags = {
    Environment = "Production"
    Pattern     = "MultiRegion"
    ManagedBy   = "Terraform"
  }
}
