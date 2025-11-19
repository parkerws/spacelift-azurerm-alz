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
  name     = "rg-vpn-gateway-advanced-example"
  location = "eastus"

  tags = {
    Environment = "Production"
    Purpose     = "VPN Gateway Module Advanced Example"
  }
}

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

resource "azurerm_subnet" "gateway" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.0.1.0/26"]
}

# Active-active VPN Gateway with BGP
module "vpn_gateway_active_active" {
  source = "../.."

  name                = "vng-hub-active-active-001"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  type          = "Vpn"
  vpn_type      = "RouteBased"
  sku           = "VpnGw2"
  generation    = "Generation2"
  active_active = true
  enable_bgp    = true

  subnet_id         = azurerm_subnet.gateway.id
  create_public_ips = true

  bgp_settings = {
    asn         = 65515
    peer_weight = 0
  }

  tags = {
    Environment = "Production"
    Pattern     = "ActiveActive"
    ManagedBy   = "Terraform"
  }
}

# VPN Gateway with Point-to-Site (P2S) configuration
module "vpn_gateway_p2s" {
  source = "../.."

  name                = "vng-hub-p2s-001"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  type       = "Vpn"
  vpn_type   = "RouteBased"
  sku        = "VpnGw1"
  generation = "Generation2"

  subnet_id         = azurerm_subnet.gateway.id
  create_public_ips = true

  # Point-to-site configuration
  vpn_client_configuration = {
    address_space        = ["172.16.0.0/24"]
    vpn_client_protocols = ["OpenVPN", "IkeV2"]

    root_certificate = [
      {
        name             = "RootCert"
        public_cert_data = "MIIC5z..."  # Base64 encoded certificate
      }
    ]

    revoked_certificate = []
  }

  tags = {
    Environment = "Production"
    Pattern     = "Point-to-Site"
    ManagedBy   = "Terraform"
  }
}

# VPN Gateway with Azure AD authentication (P2S)
module "vpn_gateway_aad" {
  source = "../.."

  name                = "vng-hub-aad-001"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  type       = "Vpn"
  vpn_type   = "RouteBased"
  sku        = "VpnGw1"
  generation = "Generation2"

  subnet_id         = azurerm_subnet.gateway.id
  create_public_ips = true

  # Azure AD authentication for P2S
  vpn_client_configuration = {
    address_space        = ["172.16.0.0/24"]
    vpn_client_protocols = ["OpenVPN"]
    aad_tenant           = "https://login.microsoftonline.com/${data.azurerm_client_config.current.tenant_id}"
    aad_audience         = "41b23e61-6c1e-4545-b367-cd054e0ed4b4" # Azure VPN Client ID
    aad_issuer           = "https://sts.windows.net/${data.azurerm_client_config.current.tenant_id}/"
    vpn_auth_types       = ["AAD"]

    root_certificate    = []
    revoked_certificate = []
  }

  tags = {
    Environment = "Production"
    Auth        = "AzureAD"
    ManagedBy   = "Terraform"
  }
}

data "azurerm_client_config" "current" {}

# High-performance VPN Gateway
module "vpn_gateway_high_perf" {
  source = "../.."

  name                = "vng-hub-high-perf-001"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  type       = "Vpn"
  vpn_type   = "RouteBased"
  sku        = "VpnGw5"
  generation = "Generation2"

  subnet_id         = azurerm_subnet.gateway.id
  create_public_ips = true
  active_active     = true
  enable_bgp        = true

  bgp_settings = {
    asn         = 65515
    peer_weight = 0
  }

  tags = {
    Environment = "Production"
    Performance = "High"
    ManagedBy   = "Terraform"
  }
}
