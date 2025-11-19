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

# Create a resource group
resource "azurerm_resource_group" "example" {
  name     = "rg-firewall-advanced-example"
  location = "eastus"

  tags = {
    Environment = "Production"
    Purpose     = "Azure Firewall Module Advanced Example"
  }
}

# Create hub virtual network
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

# Create AzureFirewallSubnet (minimum /26)
resource "azurerm_subnet" "firewall" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.0.0.0/26"]
}

# Create AzureFirewallManagementSubnet for forced tunneling (minimum /26)
resource "azurerm_subnet" "firewall_management" {
  name                 = "AzureFirewallManagementSubnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.0.1.0/26"]
}

# Create a public IP prefix for consistent IP allocation
resource "azurerm_public_ip_prefix" "firewall" {
  name                = "pip-prefix-firewall"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  prefix_length       = 30 # Provides 4 IPs
  sku                 = "Standard"
  zones               = ["1", "2", "3"]

  tags = {
    Purpose = "AzureFirewall"
  }
}

# Create firewall policy with Premium features
resource "azurerm_firewall_policy" "premium" {
  name                = "fw-policy-premium"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  sku                 = "Premium"

  threat_intelligence_mode = "Deny"

  dns {
    proxy_enabled = true
    servers       = []
  }

  intrusion_detection {
    mode = "Deny"
  }

  tags = {
    Environment = "Production"
  }
}

# Advanced Azure Firewall with multiple public IPs and Premium SKU
module "firewall_premium" {
  source = "../.."

  name                = "fw-hub-prod-eastus-001"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  sku_name           = "AZFW_VNet"
  sku_tier           = "Premium"
  firewall_policy_id = azurerm_firewall_policy.premium.id

  # Multiple public IPs for high throughput
  subnet_id           = azurerm_subnet.firewall.id
  public_ip_count     = 4
  public_ip_prefix_id = azurerm_public_ip_prefix.firewall.id

  # DNS settings
  dns_proxy_enabled = true
  dns_servers       = [] # Use Azure-provided DNS

  # Threat intelligence
  threat_intel_mode = "Deny"

  # Availability zones for high availability
  zones = ["1", "2", "3"]

  # SNAT private IP ranges (RFC 1918)
  private_ip_ranges = [
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16"
  ]

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
    CostCenter  = "IT-Network"
    Compliance  = "PCI-DSS"
  }
}

# Standard firewall with forced tunneling
module "firewall_forced_tunnel" {
  source = "../.."

  name                = "fw-forced-tunnel-001"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  sku_name           = "AZFW_VNet"
  sku_tier           = "Standard"
  firewall_policy_id = azurerm_firewall_policy.premium.id

  # Single public IP
  subnet_id       = azurerm_subnet.firewall.id
  public_ip_count = 1

  # Management IP for forced tunneling
  management_ip_configuration = {
    name                 = "mgmt-ipconfig"
    subnet_id            = azurerm_subnet.firewall_management.id
    public_ip_address_id = azurerm_public_ip.management.id
  }

  dns_proxy_enabled = true
  threat_intel_mode = "Alert"

  tags = {
    Environment = "Production"
    Pattern     = "ForcedTunneling"
    ManagedBy   = "Terraform"
  }
}

# Public IP for management (forced tunneling)
resource "azurerm_public_ip" "management" {
  name                = "pip-fw-management"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  sku                 = "Standard"
  allocation_method   = "Static"

  tags = {
    Purpose = "FirewallManagement"
  }
}

# Example with explicit IP configurations
module "firewall_explicit_ips" {
  source = "../.."

  name                = "fw-explicit-ips-001"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  sku_name           = "AZFW_VNet"
  sku_tier           = "Standard"
  firewall_policy_id = azurerm_firewall_policy.premium.id

  # Explicitly provided IP configurations
  ip_configurations = [
    {
      name                 = "primary-ipconfig"
      subnet_id            = azurerm_subnet.firewall.id
      public_ip_address_id = azurerm_public_ip.fw_pip_1.id
    },
    {
      name                 = "secondary-ipconfig-1"
      subnet_id            = null # Only first config needs subnet
      public_ip_address_id = azurerm_public_ip.fw_pip_2.id
    },
    {
      name                 = "secondary-ipconfig-2"
      subnet_id            = null
      public_ip_address_id = azurerm_public_ip.fw_pip_3.id
    }
  ]

  dns_proxy_enabled = true
  threat_intel_mode = "Alert"
  zones             = ["1", "2", "3"]

  tags = {
    Environment = "Production"
    Pattern     = "ExplicitIPs"
    ManagedBy   = "Terraform"
  }
}

# Explicit public IPs
resource "azurerm_public_ip" "fw_pip_1" {
  name                = "pip-fw-explicit-001"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  sku                 = "Standard"
  allocation_method   = "Static"
  zones               = ["1", "2", "3"]

  tags = {
    Purpose = "AzureFirewall-Primary"
  }
}

resource "azurerm_public_ip" "fw_pip_2" {
  name                = "pip-fw-explicit-002"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  sku                 = "Standard"
  allocation_method   = "Static"
  zones               = ["1", "2", "3"]

  tags = {
    Purpose = "AzureFirewall-Secondary"
  }
}

resource "azurerm_public_ip" "fw_pip_3" {
  name                = "pip-fw-explicit-003"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  sku                 = "Standard"
  allocation_method   = "Static"
  zones               = ["1", "2", "3"]

  tags = {
    Purpose = "AzureFirewall-Secondary"
  }
}
