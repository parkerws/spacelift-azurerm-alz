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
  name     = "rg-acr-advanced-example"
  location = "eastus"
}

resource "azurerm_virtual_network" "example" {
  name                = "vnet-acr-example"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "example" {
  name                 = "snet-acr-example"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]

  service_endpoints = ["Microsoft.ContainerRegistry"]
}

resource "azurerm_user_assigned_identity" "example" {
  name                = "id-acr-example"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
}

# Premium ACR with geo-replication, network restrictions, and webhooks
module "acr_premium" {
  source = "../.."

  name                = "acradvancedex001"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  sku                 = "Premium"

  # Enable zone redundancy in primary region
  zone_redundancy_enabled = true
  data_endpoint_enabled   = true

  # Network security
  public_network_access_enabled = false
  network_rule_bypass_option    = "AzureServices"

  network_rule_set = {
    default_action = "Deny"
    ip_rule = [
      {
        action   = "Allow"
        ip_range = "203.0.113.0/24"
      }
    ]
    virtual_network = [
      {
        action    = "Allow"
        subnet_id = azurerm_subnet.example.id
      }
    ]
  }

  # Geo-replication for high availability
  georeplications = [
    {
      location                  = "westus2"
      zone_redundancy_enabled   = true
      regional_endpoint_enabled = true
      tags = {
        Region = "WestUS2"
      }
    },
    {
      location                  = "northeurope"
      zone_redundancy_enabled   = true
      regional_endpoint_enabled = true
      tags = {
        Region = "NorthEurope"
      }
    }
  ]

  # Retention policy for untagged manifests
  retention_policy = {
    enabled = true
    days    = 30
  }

  # Content trust
  trust_policy = {
    enabled = true
  }

  # Managed identity
  identity = {
    type         = "SystemAssigned, UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.example.id]
  }

  # Webhooks for CI/CD integration (map-based pattern)
  webhooks = {
    "webhook-ci-pipeline" = {
      service_uri = "https://ci.example.com/acr-webhook"
      actions     = ["push", "delete"]
      status      = "enabled"
      scope       = "myapp:*"
      custom_headers = {
        "X-Custom-Header" = "CI-Pipeline"
      }
    }
    "webhook-production" = {
      service_uri = "https://prod.example.com/acr-webhook"
      actions     = ["push"]
      status      = "enabled"
      scope       = "prod/*:latest"
      custom_headers = {
        "X-Environment" = "Production"
      }
    }
    "webhook-security-scan" = {
      service_uri = "https://security.example.com/scan"
      actions     = ["push", "quarantine"]
      status      = "enabled"
      scope       = "*"
    }
  }

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
    Compliance  = "SOC2"
  }
}
