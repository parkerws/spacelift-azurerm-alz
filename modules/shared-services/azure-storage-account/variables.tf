variable "name" {
  description = "Specifies the name of the storage account. Only lowercase Alphanumeric characters allowed. Changing this forces a new resource to be created. This must be unique across the entire Azure service, not just within the resource group."
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.name))
    error_message = "Storage account name must be 3-24 lowercase alphanumeric characters."
  }
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the storage account. Changing this forces a new resource to be created."
  type        = string
}

variable "location" {
  description = "Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created."
  type        = string
}

variable "account_kind" {
  description = "Defines the Kind of account. Valid options are BlobStorage, BlockBlobStorage, FileStorage, Storage and StorageV2. Defaults to StorageV2."
  type        = string
  default     = "StorageV2"
  validation {
    condition     = contains(["BlobStorage", "BlockBlobStorage", "FileStorage", "Storage", "StorageV2"], var.account_kind)
    error_message = "Account kind must be one of: BlobStorage, BlockBlobStorage, FileStorage, Storage, StorageV2."
  }
}

variable "account_tier" {
  description = "Defines the Tier to use for this storage account. Valid options are Standard and Premium. For BlockBlobStorage and FileStorage accounts only Premium is valid. Changing this forces a new resource to be created."
  type        = string
  default     = "Standard"
  validation {
    condition     = contains(["Standard", "Premium"], var.account_tier)
    error_message = "Account tier must be Standard or Premium."
  }
}

variable "account_replication_type" {
  description = "Defines the type of replication to use for this storage account. Valid options are LRS, GRS, RAGRS, ZRS, GZRS and RAGZRS."
  type        = string
  default     = "LRS"
  validation {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"], var.account_replication_type)
    error_message = "Replication type must be one of: LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS."
  }
}

variable "access_tier" {
  description = "Defines the access tier for BlobStorage, FileStorage and StorageV2 accounts. Valid options are Hot and Cool. Defaults to Hot."
  type        = string
  default     = "Hot"
  validation {
    condition     = contains(["Hot", "Cool"], var.access_tier)
    error_message = "Access tier must be Hot or Cool."
  }
}

variable "enable_https_traffic_only" {
  description = "Boolean flag which forces HTTPS if enabled. Defaults to true."
  type        = bool
  default     = true
}

variable "min_tls_version" {
  description = "The minimum supported TLS version for the storage account. Possible values are TLS1_0, TLS1_1, and TLS1_2. Defaults to TLS1_2."
  type        = string
  default     = "TLS1_2"
  validation {
    condition     = contains(["TLS1_0", "TLS1_1", "TLS1_2"], var.min_tls_version)
    error_message = "Min TLS version must be TLS1_0, TLS1_1, or TLS1_2."
  }
}

variable "allow_nested_items_to_be_public" {
  description = "Allow or disallow nested items within this Account to opt into being public. Defaults to false."
  type        = bool
  default     = false
}

variable "shared_access_key_enabled" {
  description = "Indicates whether the storage account permits requests to be authorized with the account access key via Shared Key. If false, then all requests, including shared access signatures, must be authorized with Azure Active Directory (Azure AD). Defaults to true."
  type        = bool
  default     = true
}

variable "public_network_access_enabled" {
  description = "Whether the public network access is enabled. Defaults to true."
  type        = bool
  default     = true
}

variable "default_to_oauth_authentication" {
  description = "Default to Azure Active Directory authorization in the Azure portal when accessing the Storage Account. Defaults to false."
  type        = bool
  default     = false
}

variable "is_hns_enabled" {
  description = "Is Hierarchical Namespace enabled? This can be used with Azure Data Lake Storage Gen 2. Changing this forces a new resource to be created."
  type        = bool
  default     = false
}

variable "nfsv3_enabled" {
  description = "Is NFSv3 protocol enabled? Changing this forces a new resource to be created. Defaults to false."
  type        = bool
  default     = false
}

variable "large_file_share_enabled" {
  description = "Is Large File Share enabled? Defaults to false."
  type        = bool
  default     = false
}

variable "sftp_enabled" {
  description = "Boolean, enable SFTP for the storage account. Defaults to false."
  type        = bool
  default     = false
}

variable "infrastructure_encryption_enabled" {
  description = "Is infrastructure encryption enabled? Changing this forces a new resource to be created. Defaults to false."
  type        = bool
  default     = false
}

variable "identity" {
  description = "Managed identity configuration."
  type = object({
    type         = string
    identity_ids = optional(list(string), [])
  })
  default = null
  validation {
    condition = var.identity == null || (
      contains(["SystemAssigned", "UserAssigned", "SystemAssigned, UserAssigned"], var.identity.type)
    )
    error_message = "Identity type must be SystemAssigned, UserAssigned, or 'SystemAssigned, UserAssigned'."
  }
}

variable "customer_managed_key" {
  description = "Customer managed key configuration for encryption."
  type = object({
    key_vault_key_id          = string
    user_assigned_identity_id = string
  })
  default = null
}

variable "network_rules" {
  description = "Network rules configuration."
  type = object({
    default_action             = string
    bypass                     = optional(list(string), ["AzureServices"])
    ip_rules                   = optional(list(string), [])
    virtual_network_subnet_ids = optional(list(string), [])
  })
  default = null
  validation {
    condition = var.network_rules == null || (
      contains(["Allow", "Deny"], var.network_rules.default_action)
    )
    error_message = "Network rules default_action must be Allow or Deny."
  }
}

variable "blob_properties" {
  description = "Blob properties configuration."
  type = object({
    versioning_enabled            = optional(bool, false)
    change_feed_enabled           = optional(bool, false)
    change_feed_retention_in_days = optional(number, null)
    last_access_time_enabled      = optional(bool, false)
    default_service_version       = optional(string, null)
    delete_retention_policy = optional(object({
      days = number
    }), null)
    container_delete_retention_policy = optional(object({
      days = number
    }), null)
  })
  default = null
}

variable "static_website" {
  description = "Static website configuration."
  type = object({
    index_document     = optional(string, "index.html")
    error_404_document = optional(string, "404.html")
  })
  default = null
}

variable "containers" {
  description = "Map of blob containers to create."
  type = map(object({
    container_access_type = optional(string, "private")
  }))
  default = {}
  validation {
    condition = alltrue([
      for k, v in var.containers : contains(["blob", "container", "private"], v.container_access_type)
    ])
    error_message = "Container access type must be blob, container, or private."
  }
}

variable "file_shares" {
  description = "Map of file shares to create."
  type = map(object({
    quota        = number
    access_tier  = optional(string, "Hot")
    enabled_protocol = optional(string, "SMB")
  }))
  default = {}
  validation {
    condition = alltrue([
      for k, v in var.file_shares : contains(["Hot", "Cool", "TransactionOptimized", "Premium"], v.access_tier)
    ])
    error_message = "File share access tier must be Hot, Cool, TransactionOptimized, or Premium."
  }
}

variable "queues" {
  description = "List of queue names to create."
  type        = list(string)
  default     = []
}

variable "tables" {
  description = "List of table names to create."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  type        = map(string)
  default     = {}
}
