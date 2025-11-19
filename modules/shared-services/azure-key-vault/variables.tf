variable "name" {
  description = "The name of the Key Vault. Must be globally unique. Changing this forces a new resource to be created."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9-]{1,22}[a-zA-Z0-9]$", var.name))
    error_message = "Key Vault name must be 3-24 characters, start with letter, end with letter/number, contain only alphanumerics and hyphens."
  }
}

variable "resource_group_name" {
  description = "The name of the resource group. Changing this forces a new resource to be created."
  type        = string
}

variable "location" {
  description = "The Azure region. Changing this forces a new resource to be created."
  type        = string
}

variable "sku_name" {
  description = "The SKU name. Possible values are standard and premium."
  type        = string
  default     = "standard"
  validation {
    condition     = contains(["standard", "premium"], var.sku_name)
    error_message = "SKU must be standard or premium."
  }
}

variable "tenant_id" {
  description = "The Azure AD tenant ID. Defaults to current tenant."
  type        = string
  default     = null
}

variable "enabled_for_deployment" {
  description = "Allow Azure Virtual Machines to retrieve certificates."
  type        = bool
  default     = false
}

variable "enabled_for_disk_encryption" {
  description = "Allow Azure Disk Encryption to retrieve secrets and unwrap keys."
  type        = bool
  default     = false
}

variable "enabled_for_template_deployment" {
  description = "Allow Azure Resource Manager to retrieve secrets."
  type        = bool
  default     = false
}

variable "enable_rbac_authorization" {
  description = "Use Azure RBAC for authorization of data actions instead of access policies."
  type        = bool
  default     = true
}

variable "purge_protection_enabled" {
  description = "Enable purge protection (cannot be disabled once enabled)."
  type        = bool
  default     = true
}

variable "soft_delete_retention_days" {
  description = "Soft delete retention in days (7-90)."
  type        = number
  default     = 90
  validation {
    condition     = var.soft_delete_retention_days >= 7 && var.soft_delete_retention_days <= 90
    error_message = "Retention must be 7-90 days."
  }
}

variable "public_network_access_enabled" {
  description = "Enable public network access."
  type        = bool
  default     = true
}

variable "network_acls" {
  description = "Network ACLs configuration."
  type = object({
    bypass                     = string
    default_action             = string
    ip_rules                   = optional(list(string), [])
    virtual_network_subnet_ids = optional(list(string), [])
  })
  default = null
}

variable "tags" {
  description = "Tags to assign."
  type        = map(string)
  default     = {}
}
