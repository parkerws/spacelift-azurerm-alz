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
  name     = "rg-bastion-advanced-example"
  location = "eastus"

  tags = {
    Environment = "Production"
    Purpose     = "Bastion Module Advanced Example"
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

resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.0.2.0/26"]
}

# Standard Bastion with all features
module "bastion_standard" {
  source = "../.."

  name                = "bastion-hub-standard-001"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  sku         = "Standard"
  scale_units = 4
  subnet_id   = azurerm_subnet.bastion.id

  create_public_ip = true

  # Enable Standard features
  copy_paste_enabled     = true
  file_copy_enabled      = true
  ip_connect_enabled     = true
  tunneling_enabled      = true
  shareable_link_enabled = false # Often disabled for security
  kerberos_enabled       = false

  # Availability zones for high availability
  zones = ["1", "2", "3"]

  tags = {
    Environment = "Production"
    SKU         = "Standard"
    ManagedBy   = "Terraform"
  }
}

# Premium Bastion (maximum features)
module "bastion_premium" {
  source = "../.."

  name                = "bastion-hub-premium-001"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  sku         = "Premium"
  scale_units = 10
  subnet_id   = azurerm_subnet.bastion.id

  create_public_ip = true

  # Enable all features
  copy_paste_enabled     = true
  file_copy_enabled      = true
  ip_connect_enabled     = true
  tunneling_enabled      = true
  shareable_link_enabled = true
  kerberos_enabled       = true

  zones = ["1", "2", "3"]

  tags = {
    Environment = "Production"
    SKU         = "Premium"
    ManagedBy   = "Terraform"
  }
}

# Bastion with existing public IP
resource "azurerm_public_ip" "bastion_custom" {
  name                = "pip-bastion-custom"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  sku                 = "Standard"
  allocation_method   = "Static"
  zones               = ["1", "2", "3"]

  tags = {
    Purpose = "AzureBastion"
  }
}

module "bastion_custom_ip" {
  source = "../.."

  name                = "bastion-custom-ip-001"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  sku       = "Standard"
  subnet_id = azurerm_subnet.bastion.id

  # Use existing public IP
  create_public_ip      = false
  public_ip_address_id  = azurerm_public_ip.bastion_custom.id

  copy_paste_enabled = true
  tunneling_enabled  = true

  tags = {
    Environment = "Production"
    Pattern     = "CustomIP"
    ManagedBy   = "Terraform"
  }
}
