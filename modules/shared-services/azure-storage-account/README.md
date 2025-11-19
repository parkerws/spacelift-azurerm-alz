# Azure Storage Account Module

Terraform module for Azure Storage Account with support for blobs, files, queues, and tables.

## Features

- StorageV2, BlobStorage, BlockBlobStorage, and FileStorage account kinds
- Standard and Premium tiers
- LRS, GRS, RAGRS, ZRS, GZRS, and RAGZRS replication
- Network ACLs with virtual network and IP rules
- Blob versioning and change feed
- Static website hosting
- Customer-managed encryption keys
- Managed identity support
- Hierarchical namespace for Data Lake Gen2
- NFSv3 and SFTP support
- Containers, file shares, queues, and tables

## Usage

### Basic Configuration

```hcl
module "storage" {
  source = "../../modules/shared-services/azure-storage-account"

  name                     = "stprodlogs001"
  resource_group_name      = azurerm_resource_group.shared.name
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  containers = {
    "logs" = {
      container_access_type = "private"
    }
    "diagnostics" = {
      container_access_type = "private"
    }
  }

  tags = {
    Environment = "Production"
  }
}
```

### Advanced Configuration

```hcl
module "storage_advanced" {
  source = "../../modules/shared-services/azure-storage-account"

  name                     = "stproddata001"
  resource_group_name      = azurerm_resource_group.shared.name
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "GZRS"

  # Security settings
  enable_https_traffic_only       = true
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  shared_access_key_enabled       = false
  public_network_access_enabled   = false

  # Network restrictions
  network_rules = {
    default_action             = "Deny"
    bypass                     = ["AzureServices"]
    ip_rules                   = ["203.0.113.0/24"]
    virtual_network_subnet_ids = [azurerm_subnet.storage.id]
  }

  # Blob features
  blob_properties = {
    versioning_enabled       = true
    change_feed_enabled      = true
    last_access_time_enabled = true
    delete_retention_policy = {
      days = 30
    }
    container_delete_retention_policy = {
      days = 7
    }
  }

  # Data Lake Gen2
  is_hns_enabled = true

  # Managed identity
  identity = {
    type = "SystemAssigned"
  }

  # Create containers
  containers = {
    "data" = {
      container_access_type = "private"
    }
    "archives" = {
      container_access_type = "private"
    }
  }

  # Create file shares
  file_shares = {
    "terraform-state" = {
      quota       = 100
      access_tier = "TransactionOptimized"
    }
  }

  tags = {
    Environment = "Production"
    DataClassification = "Confidential"
  }
}
```

## License

MIT License - see [LICENSE](../../../LICENSE) for details.
