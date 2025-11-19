# Hub Network Stack Template
# This is the template used by hub stacks created by the factory

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

# Variables will be set via Spacelift environment variables
variable "environment" {
  description = "Environment name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "hub_vnet_address_space" {
  description = "Hub VNet address space"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

locals {
  name_prefix = "hub-${var.environment}"
  common_tags = merge(
    var.tags,
    {
      Environment = var.environment
      ManagedBy   = "Spacelift"
      Purpose     = "Hub-Connectivity"
    }
  )
}

# Resource Group
resource "azurerm_resource_group" "hub" {
  name     = "rg-${local.name_prefix}-${var.location}"
  location = var.location
  tags     = local.common_tags
}

# Hub VNet
module "hub_vnet" {
  source = "../../modules/networking/azure-vnet"

  name                = "vnet-${local.name_prefix}"
  resource_group_name = azurerm_resource_group.hub.name
  location            = azurerm_resource_group.hub.location
  address_space       = var.hub_vnet_address_space

  tags = local.common_tags
}

# Azure Firewall Subnet
module "firewall_subnet" {
  source = "../../modules/networking/azure-subnet"

  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = module.hub_vnet.name
  address_prefixes     = [cidrsubnet(var.hub_vnet_address_space[0], 10, 0)]
}

# Gateway Subnet
module "gateway_subnet" {
  source = "../../modules/networking/azure-subnet"

  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = module.hub_vnet.name
  address_prefixes     = [cidrsubnet(var.hub_vnet_address_space[0], 11, 2)]
}

# Bastion Subnet
module "bastion_subnet" {
  source = "../../modules/networking/azure-subnet"

  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = module.hub_vnet.name
  address_prefixes     = [cidrsubnet(var.hub_vnet_address_space[0], 11, 4)]
}

# Azure Firewall
module "firewall" {
  source = "../../modules/hub/azure-firewall"

  name                = "fw-${local.name_prefix}"
  resource_group_name = azurerm_resource_group.hub.name
  location            = azurerm_resource_group.hub.location

  subnet_id       = module.firewall_subnet.id
  public_ip_count = var.environment == "production" ? 2 : 1
  sku_name        = "AZFW_VNet"
  sku_tier        = var.environment == "production" ? "Standard" : "Standard"

  tags = local.common_tags
}

# VPN Gateway
module "vpn_gateway" {
  source = "../../modules/hub/azure-vpn-gateway"

  name                = "vpngw-${local.name_prefix}"
  resource_group_name = azurerm_resource_group.hub.name
  location            = azurerm_resource_group.hub.location

  subnet_id = module.gateway_subnet.id
  type      = "Vpn"
  vpn_type  = "RouteBased"
  sku       = var.environment == "production" ? "VpnGw2" : "VpnGw1"

  enable_bgp         = true
  active_active_mode = var.environment == "production"

  tags = local.common_tags
}

# Azure Bastion
module "bastion" {
  source = "../../modules/hub/azure-bastion"

  name                = "bas-${local.name_prefix}"
  resource_group_name = azurerm_resource_group.hub.name
  location            = azurerm_resource_group.hub.location

  subnet_id = module.bastion_subnet.id
  sku       = var.environment == "production" ? "Standard" : "Basic"

  tags = local.common_tags
}

# Outputs for spoke consumption
output "hub_vnet_id" {
  description = "Hub VNet ID for peering"
  value       = module.hub_vnet.id
}

output "hub_vnet_name" {
  description = "Hub VNet name"
  value       = module.hub_vnet.name
}

output "firewall_private_ip" {
  description = "Azure Firewall private IP for routing"
  value       = module.firewall.private_ip_address
}

output "resource_group_name" {
  description = "Hub resource group name"
  value       = azurerm_resource_group.hub.name
}
