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
  name     = "rg-storage-advanced-example"
  location = "eastus"
}

resource "azurerm_virtual_network" "example" {
  name                = "vnet-storage-example"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "example" {
  name                 = "snet-storage-example"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]

  service_endpoints = ["Microsoft.Storage"]
}

# Advanced storage account with all features
module "storage_advanced" {
  source = "../.."

  name                     = "stadvancedex001"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "GZRS"
  access_tier              = "Hot"

  # Security hardening
  enable_https_traffic_only       = true
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  shared_access_key_enabled       = false
  public_network_access_enabled   = false
  default_to_oauth_authentication = true
  infrastructure_encryption_enabled = true

  # Network restrictions
  network_rules = {
    default_action = "Deny"
    bypass         = ["AzureServices", "Logging", "Metrics"]
    ip_rules       = ["203.0.113.0/24", "198.51.100.0/24"]
    virtual_network_subnet_ids = [
      azurerm_subnet.example.id
    ]
  }

  # Advanced blob features
  blob_properties = {
    versioning_enabled            = true
    change_feed_enabled           = true
    change_feed_retention_in_days = 30
    last_access_time_enabled      = true
    default_service_version       = "2020-06-12"

    delete_retention_policy = {
      days = 30
    }

    container_delete_retention_policy = {
      days = 7
    }
  }

  # Data Lake Gen2 support
  is_hns_enabled = true

  # Managed identity
  identity = {
    type = "SystemAssigned"
  }

  # Static website hosting
  static_website = {
    index_document     = "index.html"
    error_404_document = "404.html"
  }

  # Blob containers
  containers = {
    "data-lake" = {
      container_access_type = "private"
    }
    "archives" = {
      container_access_type = "private"
    }
    "backups" = {
      container_access_type = "private"
    }
  }

  # File shares for SMB/NFS
  file_shares = {
    "terraform-state" = {
      quota       = 100
      access_tier = "TransactionOptimized"
    }
    "shared-files" = {
      quota       = 500
      access_tier = "Hot"
    }
  }

  # Queues for messaging
  queues = [
    "processing-queue",
    "notifications-queue"
  ]

  # Tables for NoSQL data
  tables = [
    "logs-table",
    "metrics-table"
  ]

  tags = {
    Environment        = "Production"
    ManagedBy          = "Terraform"
    DataClassification = "Confidential"
    Compliance         = "SOC2"
  }
}
