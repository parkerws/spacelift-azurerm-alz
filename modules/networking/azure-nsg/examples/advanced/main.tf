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
  name     = "rg-nsg-advanced-example"
  location = "eastus"

  tags = {
    Environment = "Production"
    Purpose     = "NSG Module Advanced Example"
  }
}

# Create application security groups
resource "azurerm_application_security_group" "web" {
  name                = "asg-web"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  tags = {
    Tier = "Web"
  }
}

resource "azurerm_application_security_group" "app" {
  name                = "asg-app"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  tags = {
    Tier = "Application"
  }
}

resource "azurerm_application_security_group" "data" {
  name                = "asg-data"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  tags = {
    Tier = "Data"
  }
}

# Advanced NSG for web tier
module "nsg_web" {
  source = "../.."

  name                = "nsg-web-tier-001"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  security_rules = [
    {
      name                                       = "AllowHTTPSFromInternet"
      description                                = "Allow HTTPS from internet to web tier"
      priority                                   = 100
      direction                                  = "Inbound"
      access                                     = "Allow"
      protocol                                   = "Tcp"
      source_port_range                          = "*"
      destination_port_range                     = "443"
      source_address_prefix                      = "Internet"
      destination_application_security_group_ids = [azurerm_application_security_group.web.id]
    },
    {
      name                                       = "AllowHTTPFromInternet"
      description                                = "Allow HTTP from internet to web tier (redirect to HTTPS)"
      priority                                   = 110
      direction                                  = "Inbound"
      access                                     = "Allow"
      protocol                                   = "Tcp"
      source_port_range                          = "*"
      destination_port_range                     = "80"
      source_address_prefix                      = "Internet"
      destination_application_security_group_ids = [azurerm_application_security_group.web.id]
    },
    {
      name                                  = "AllowWebToApp"
      description                           = "Allow web tier to communicate with app tier"
      priority                              = 200
      direction                             = "Outbound"
      access                                = "Allow"
      protocol                              = "Tcp"
      source_port_range                     = "*"
      destination_port_ranges               = ["8080", "8443"]
      source_application_security_group_ids = [azurerm_application_security_group.web.id]
      destination_application_security_group_ids = [azurerm_application_security_group.app.id]
    }
  ]

  tags = {
    Environment = "Production"
    Tier        = "Web"
    ManagedBy   = "Terraform"
  }
}

# Advanced NSG for application tier
module "nsg_app" {
  source = "../.."

  name                = "nsg-app-tier-001"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  security_rules = [
    {
      name                                       = "AllowWebToApp"
      description                                = "Allow traffic from web tier"
      priority                                   = 100
      direction                                  = "Inbound"
      access                                     = "Allow"
      protocol                                   = "Tcp"
      source_port_range                          = "*"
      destination_port_ranges                    = ["8080", "8443"]
      source_application_security_group_ids      = [azurerm_application_security_group.web.id]
      destination_application_security_group_ids = [azurerm_application_security_group.app.id]
    },
    {
      name                                  = "AllowAppToData"
      description                           = "Allow app tier to communicate with data tier"
      priority                              = 200
      direction                             = "Outbound"
      access                                = "Allow"
      protocol                              = "Tcp"
      source_port_range                     = "*"
      destination_port_ranges               = ["1433", "5432", "3306"]
      source_application_security_group_ids = [azurerm_application_security_group.app.id]
      destination_application_security_group_ids = [azurerm_application_security_group.data.id]
    },
    {
      name                                  = "AllowAppToKeyVault"
      description                           = "Allow app tier to access Key Vault"
      priority                              = 210
      direction                             = "Outbound"
      access                                = "Allow"
      protocol                              = "Tcp"
      source_port_range                     = "*"
      destination_port_range                = "443"
      source_application_security_group_ids = [azurerm_application_security_group.app.id]
      destination_address_prefix            = "AzureKeyVault"
    }
  ]

  tags = {
    Environment = "Production"
    Tier        = "Application"
    ManagedBy   = "Terraform"
  }
}

# Advanced NSG for data tier
module "nsg_data" {
  source = "../.."

  name                = "nsg-data-tier-001"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  security_rules = [
    {
      name                                       = "AllowAppToData"
      description                                = "Allow traffic from app tier only"
      priority                                   = 100
      direction                                  = "Inbound"
      access                                     = "Allow"
      protocol                                   = "Tcp"
      source_port_range                          = "*"
      destination_port_ranges                    = ["1433", "5432", "3306"]
      source_application_security_group_ids      = [azurerm_application_security_group.app.id]
      destination_application_security_group_ids = [azurerm_application_security_group.data.id]
    },
    {
      name                                       = "DenyAllInbound"
      description                                = "Deny all other inbound traffic to data tier"
      priority                                   = 4096
      direction                                  = "Inbound"
      access                                     = "Deny"
      protocol                                   = "*"
      source_port_range                          = "*"
      destination_port_range                     = "*"
      source_address_prefix                      = "*"
      destination_application_security_group_ids = [azurerm_application_security_group.data.id]
    }
  ]

  tags = {
    Environment = "Production"
    Tier        = "Data"
    ManagedBy   = "Terraform"
  }
}

# NSG with multiple port ranges
module "nsg_multi_port" {
  source = "../.."

  name                = "nsg-multi-port-001"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  security_rules = [
    {
      name                       = "AllowMultiplePorts"
      description                = "Allow multiple ports for microservices"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_ranges    = ["8080", "8081", "8082", "8083", "9090", "9091"]
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "VirtualNetwork"
    },
    {
      name                       = "AllowMultipleSources"
      description                = "Allow from multiple source IP ranges"
      priority                   = 110
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      source_address_prefixes    = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
      destination_port_range     = "443"
      destination_address_prefix = "*"
    }
  ]

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
    Example     = "Advanced"
  }
}
