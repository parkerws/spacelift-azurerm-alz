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
  name     = "rg-subnet-advanced-example"
  location = "eastus"

  tags = {
    Environment = "Production"
    Purpose     = "Subnet Module Advanced Example"
  }
}

# Create a virtual network
resource "azurerm_virtual_network" "example" {
  name                = "vnet-example-eastus-001"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  address_space       = ["10.0.0.0/16"]

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

# Advanced subnet with service endpoints and delegation
module "subnet_aks" {
  source = "../.."

  name                 = "snet-aks-001"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]

  # Disable default outbound access for enhanced security
  default_outbound_access_enabled = false

  # Service endpoints for Azure services
  service_endpoints = [
    "Microsoft.KeyVault",
    "Microsoft.Storage",
    "Microsoft.ContainerRegistry"
  ]

  # Delegation for AKS
  delegations = [
    {
      name = "aks-delegation"
      service_delegation = {
        name = "Microsoft.ContainerService/managedClusters"
        actions = [
          "Microsoft.Network/virtualNetworks/subnets/join/action"
        ]
      }
    }
  ]

  # Enable network policies for private endpoints (NSG and route tables)
  private_endpoint_network_policies = "NetworkSecurityGroupEnabled"

  # Disable network policies for private link services
  private_link_service_network_policies_enabled = false
}

# Subnet for Azure SQL with service endpoints
module "subnet_data" {
  source = "../.."

  name                 = "snet-data-001"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.2.0/24"]

  service_endpoints = [
    "Microsoft.Sql",
    "Microsoft.Storage"
  ]

  # Enable all network policies for private endpoints
  private_endpoint_network_policies = "Enabled"
}

# Subnet for App Service with delegation
module "subnet_app_service" {
  source = "../.."

  name                 = "snet-app-service-001"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.3.0/24"]

  delegations = [
    {
      name = "app-service-delegation"
      service_delegation = {
        name = "Microsoft.Web/serverFarms"
        actions = [
          "Microsoft.Network/virtualNetworks/subnets/action"
        ]
      }
    }
  ]
}

# Subnet for Azure NetApp Files
module "subnet_netapp" {
  source = "../.."

  name                 = "snet-netapp-001"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.4.0/24"]

  delegations = [
    {
      name = "netapp-delegation"
      service_delegation = {
        name = "Microsoft.NetApp/volumes"
        actions = [
          "Microsoft.Network/networkinterfaces/*",
          "Microsoft.Network/virtualNetworks/subnets/join/action"
        ]
      }
    }
  ]
}
