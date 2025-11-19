# Spoke Network Stack Template
# This is the template used by spoke stacks created by the factory

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

variable "spoke_vnet_address_space" {
  description = "Spoke VNet address space"
  type        = list(string)
  default     = ["10.1.0.0/16"]
}

variable "workload_subnet_prefix" {
  description = "Workload subnet prefix"
  type        = string
  default     = "10.1.0.0/24"
}

variable "data_subnet_prefix" {
  description = "Data subnet prefix"
  type        = string
  default     = "10.1.1.0/24"
}

variable "hub_vnet_id" {
  description = "Hub VNet ID for peering (from stack dependency)"
  type        = string
}

variable "hub_vnet_name" {
  description = "Hub VNet name (from stack dependency)"
  type        = string
}

variable "hub_resource_group_name" {
  description = "Hub resource group name (from stack dependency)"
  type        = string
}

variable "firewall_private_ip" {
  description = "Azure Firewall private IP for UDR (from stack dependency)"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

locals {
  # Extract spoke name from Terraform workspace or use default
  spoke_name  = terraform.workspace != "default" ? terraform.workspace : "spoke-001"
  name_prefix = "${local.spoke_name}-${var.environment}"

  common_tags = merge(
    var.tags,
    {
      Environment = var.environment
      ManagedBy   = "Spacelift"
      Purpose     = "Spoke-Workload"
    }
  )
}

# Resource Group
resource "azurerm_resource_group" "spoke" {
  name     = "rg-${local.name_prefix}-${var.location}"
  location = var.location
  tags     = local.common_tags
}

# Spoke VNet
module "spoke_vnet" {
  source = "../../modules/networking/azure-vnet"

  name                = "vnet-${local.name_prefix}"
  resource_group_name = azurerm_resource_group.spoke.name
  location            = azurerm_resource_group.spoke.location
  address_space       = var.spoke_vnet_address_space

  tags = local.common_tags
}

# Workload Subnet with NSG
module "workload_subnet" {
  source = "../../modules/networking/azure-subnet"

  name                 = "snet-workload"
  resource_group_name  = azurerm_resource_group.spoke.name
  virtual_network_name = module.spoke_vnet.name
  address_prefixes     = [var.workload_subnet_prefix]

  service_endpoints = [
    "Microsoft.KeyVault",
    "Microsoft.Storage",
    "Microsoft.Sql"
  ]
}

module "workload_nsg" {
  source = "../../modules/networking/azure-nsg"

  name                = "nsg-workload"
  resource_group_name = azurerm_resource_group.spoke.name
  location            = azurerm_resource_group.spoke.location

  tags = local.common_tags
}

resource "azurerm_subnet_network_security_group_association" "workload" {
  subnet_id                 = module.workload_subnet.id
  network_security_group_id = module.workload_nsg.id
}

# Data Subnet with NSG
module "data_subnet" {
  source = "../../modules/networking/azure-subnet"

  name                 = "snet-data"
  resource_group_name  = azurerm_resource_group.spoke.name
  virtual_network_name = module.spoke_vnet.name
  address_prefixes     = [var.data_subnet_prefix]

  service_endpoints = [
    "Microsoft.Sql",
    "Microsoft.Storage"
  ]
}

module "data_nsg" {
  source = "../../modules/networking/azure-nsg"

  name                = "nsg-data"
  resource_group_name = azurerm_resource_group.spoke.name
  location            = azurerm_resource_group.spoke.location

  tags = local.common_tags
}

resource "azurerm_subnet_network_security_group_association" "data" {
  subnet_id                 = module.data_subnet.id
  network_security_group_id = module.data_nsg.id
}

# Route Table (UDR to firewall)
module "route_table" {
  source = "../../modules/networking/azure-route-table"

  name                = "rt-${local.name_prefix}"
  resource_group_name = azurerm_resource_group.spoke.name
  location            = azurerm_resource_group.spoke.location

  routes = [
    {
      name                   = "default-via-firewall"
      address_prefix         = "0.0.0.0/0"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = var.firewall_private_ip
    }
  ]

  tags = local.common_tags
}

# Associate route table with subnets
resource "azurerm_subnet_route_table_association" "workload" {
  subnet_id      = module.workload_subnet.id
  route_table_id = module.route_table.id
}

resource "azurerm_subnet_route_table_association" "data" {
  subnet_id      = module.data_subnet.id
  route_table_id = module.route_table.id
}

# VNet Peering to Hub
module "spoke_to_hub_peering" {
  source = "../../modules/hub/azure-vnet-peering"

  source_vnet_name         = module.spoke_vnet.name
  source_resource_group    = azurerm_resource_group.spoke.name
  destination_vnet_name    = var.hub_vnet_name
  destination_resource_group = var.hub_resource_group_name

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = true
}

# Outputs
output "spoke_vnet_id" {
  description = "Spoke VNet ID"
  value       = module.spoke_vnet.id
}

output "spoke_vnet_name" {
  description = "Spoke VNet name"
  value       = module.spoke_vnet.name
}

output "resource_group_name" {
  description = "Spoke resource group name"
  value       = azurerm_resource_group.spoke.name
}

output "workload_subnet_id" {
  description = "Workload subnet ID"
  value       = module.workload_subnet.id
}

output "data_subnet_id" {
  description = "Data subnet ID"
  value       = module.data_subnet.id
}
