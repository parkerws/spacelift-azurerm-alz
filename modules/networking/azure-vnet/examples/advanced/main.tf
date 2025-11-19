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
  name     = "rg-vnet-advanced-example"
  location = "eastus"

  tags = {
    Environment = "Production"
    Purpose     = "VNet Module Advanced Example"
  }
}

# Create a DDoS Protection Plan
resource "azurerm_network_ddos_protection_plan" "example" {
  name                = "ddos-protection-plan-example"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

# Advanced VNet with all features
module "vnet" {
  source = "../.."

  name                = "vnet-hub-eastus-001"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  address_space       = ["10.0.0.0/16", "10.1.0.0/16"]

  # Custom DNS servers (e.g., on-premises DNS or Azure Firewall)
  dns_servers = ["10.0.0.4", "10.0.0.5"]

  # DDoS Protection
  ddos_protection_plan = {
    id     = azurerm_network_ddos_protection_plan.example.id
    enable = true
  }

  # VNet encryption (requires supported VM SKUs)
  encryption = {
    enforcement = "AllowUnencrypted"
  }

  # Flow timeout for connection tracking
  flow_timeout_in_minutes = 10

  # BGP community for ExpressRoute scenarios
  bgp_community = "12076:20001"

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
    Example     = "Advanced"
    CostCenter  = "IT-Network"
    Compliance  = "PCI-DSS"
  }
}
