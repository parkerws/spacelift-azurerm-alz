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
  name     = "rg-log-analytics-advanced-example"
  location = "eastus"

  tags = {
    Environment = "Production"
    Purpose     = "Log Analytics Module Advanced Example"
  }
}

# Advanced workspace with solutions
module "log_analytics" {
  source = "../.."

  name                = "law-prod-eastus-001"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  sku               = "PerGB2018"
  retention_in_days = 90
  daily_quota_gb    = 10

  internet_ingestion_enabled = true
  internet_query_enabled     = true

  identity_type = "SystemAssigned"

  solutions = {
    "ContainerInsights" = {
      publisher = "Microsoft"
      product   = "OMSGallery/ContainerInsights"
    }
    "SecurityInsights" = {
      publisher = "Microsoft"
      product   = "OMSGallery/SecurityInsights"
    }
    "VMInsights" = {
      publisher = "Microsoft"
      product   = "OMSGallery/VMInsights"
    }
  }

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
    CostCenter  = "IT-Operations"
  }
}
