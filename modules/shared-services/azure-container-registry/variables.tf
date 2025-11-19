variable "name" {
  description = "The name of the Container Registry. Changing this forces a new resource to be created."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9]{5,50}$", var.name))
    error_message = "Name must be 5-50 alphanumeric characters (no hyphens allowed)."
  }
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the Container Registry. Changing this forces a new resource to be created."
  type        = string
}

variable "location" {
  description = "Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created."
  type        = string
}

variable "sku" {
  description = "The SKU name of the container registry. Possible values are Basic, Standard and Premium."
  type        = string
  default     = "Standard"
  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku)
    error_message = "SKU must be Basic, Standard, or Premium."
  }
}

variable "admin_enabled" {
  description = "Specifies whether the admin user is enabled. Defaults to false."
  type        = bool
  default     = false
}

variable "public_network_access_enabled" {
  description = "Whether public network access is allowed for the container registry. Defaults to true."
  type        = bool
  default     = true
}

variable "quarantine_policy_enabled" {
  description = "Boolean value that indicates whether quarantine policy is enabled. Only available with Premium SKU."
  type        = bool
  default     = false
}

variable "zone_redundancy_enabled" {
  description = "Whether zone redundancy is enabled for this Container Registry. Only available with Premium SKU. Changing this forces a new resource to be created."
  type        = bool
  default     = false
}

variable "export_policy_enabled" {
  description = "Boolean value that indicates whether export policy is enabled. Defaults to true. Only available with Premium SKU."
  type        = bool
  default     = true
}

variable "anonymous_pull_enabled" {
  description = "Whether allows anonymous (unauthenticated) pull access to this Container Registry. Only available with Standard and Premium SKU."
  type        = bool
  default     = false
}

variable "data_endpoint_enabled" {
  description = "Whether to enable dedicated data endpoints for this Container Registry. Only available with Premium SKU."
  type        = bool
  default     = false
}

variable "network_rule_bypass_option" {
  description = "Whether to allow trusted Azure services to access a network restricted Container Registry. Possible values are None and AzureServices. Only available with Premium SKU."
  type        = string
  default     = "AzureServices"
  validation {
    condition     = contains(["None", "AzureServices"], var.network_rule_bypass_option)
    error_message = "Network rule bypass option must be None or AzureServices."
  }
}

variable "network_rule_set" {
  description = "Network rule set configuration for the container registry. Only available with Premium SKU."
  type = object({
    default_action = string
    ip_rule = optional(list(object({
      action   = string
      ip_range = string
    })), [])
    virtual_network = optional(list(object({
      action    = string
      subnet_id = string
    })), [])
  })
  default = null
  validation {
    condition = var.network_rule_set == null || (
      contains(["Allow", "Deny"], var.network_rule_set.default_action)
    )
    error_message = "Network rule set default_action must be Allow or Deny."
  }
}

variable "retention_policy" {
  description = "Retention policy for untagged manifests. Only available with Premium SKU."
  type = object({
    days    = optional(number, 7)
    enabled = optional(bool, false)
  })
  default = null
  validation {
    condition = var.retention_policy == null || (
      var.retention_policy.days >= 0 && var.retention_policy.days <= 365
    )
    error_message = "Retention policy days must be between 0 and 365."
  }
}

variable "trust_policy" {
  description = "Content trust policy configuration. Only available with Premium SKU."
  type = object({
    enabled = bool
  })
  default = null
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

variable "encryption" {
  description = "Encryption configuration using customer-managed keys. Only available with Premium SKU."
  type = object({
    enabled            = bool
    key_vault_key_id   = string
    identity_client_id = string
  })
  default = null
}

variable "georeplications" {
  description = "List of georeplications for the container registry. Only available with Premium SKU."
  type = list(object({
    location                  = string
    regional_endpoint_enabled = optional(bool, false)
    zone_redundancy_enabled   = optional(bool, false)
    tags                      = optional(map(string), {})
  }))
  default = []
}

variable "webhooks" {
  description = "Map of webhooks to create for the container registry."
  type = map(object({
    service_uri    = string
    actions        = list(string)
    status         = optional(string, "enabled")
    scope          = optional(string, "")
    custom_headers = optional(map(string), {})
  }))
  default = {}
  validation {
    condition = alltrue([
      for k, v in var.webhooks : alltrue([
        for action in v.actions : contains(["push", "delete", "quarantine", "chart_push", "chart_delete"], action)
      ])
    ])
    error_message = "Webhook actions must be one of: push, delete, quarantine, chart_push, chart_delete."
  }
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  type        = map(string)
  default     = {}
}
