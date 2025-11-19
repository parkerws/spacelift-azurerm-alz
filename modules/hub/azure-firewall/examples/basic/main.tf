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
  name     = "rg-firewall-basic-example"
  location = "eastus"

  tags = {
    Environment = "Development"
    Purpose     = "Azure Firewall Module Basic Example"
  }
}

# Create a virtual network
resource "azurerm_virtual_network" "example" {
  name                = "vnet-hub-example"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  address_space       = ["10.0.0.0/16"]

  tags = {
    Environment = "Development"
  }
}

# Create AzureFirewallSubnet (required name, minimum /26)
resource "azurerm_subnet" "firewall" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.0.0/26"]
}

# Create a basic firewall policy
resource "azurerm_firewall_policy" "example" {
  name                = "fw-policy-basic"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  sku                 = "Standard"

  threat_intelligence_mode = "Alert"

  tags = {
    Environment = "Development"
  }
}

# Basic Azure Firewall with single public IP
module "firewall" {
  source = "../.."

  name                = "fw-hub-example-001"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  sku_name           = "AZFW_VNet"
  sku_tier           = "Standard"
  firewall_policy_id = azurerm_firewall_policy.example.id

  # Automatically create 1 public IP
  subnet_id       = azurerm_subnet.firewall.id
  public_ip_count = 1

  # Threat intelligence
  threat_intel_mode = "Alert"

  tags = {
    Environment = "Development"
    ManagedBy   = "Terraform"
    Example     = "Basic"
  }
}
