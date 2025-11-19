variable "name" {
  description = "The name of the Log Analytics Workspace. Workspace name should include 4-63 letters, digits or '-'. The '-' shouldn't be the first or the last symbol. Changing this forces a new resource to be created."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-]{2,61}[a-zA-Z0-9]$", var.name))
    error_message = "Workspace name should include 4-63 letters, digits or '-'. The '-' shouldn't be the first or the last symbol."
  }
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the Log Analytics workspace. Changing this forces a new resource to be created."
  type        = string
}

variable "location" {
  description = "The location/region where the Log Analytics workspace is created. Changing this forces a new resource to be created."
  type        = string
}

variable "sku" {
  description = "The SKU of the Log Analytics Workspace. Possible values are Free, PerNode, Premium, Standard, Standalone, Unlimited, CapacityReservation, and PerGB2018. Defaults to PerGB2018."
  type        = string
  default     = "PerGB2018"

  validation {
    condition     = contains(["Free", "PerNode", "Premium", "Standard", "Standalone", "Unlimited", "CapacityReservation", "PerGB2018"], var.sku)
    error_message = "SKU must be one of: Free, PerNode, Premium, Standard, Standalone, Unlimited, CapacityReservation, PerGB2018."
  }
}

variable "retention_in_days" {
  description = "The workspace data retention in days. Possible values are 30-730 for PerGB2018, or 7 for Free SKU. Defaults to 30."
  type        = number
  default     = 30

  validation {
    condition     = (var.retention_in_days >= 7 && var.retention_in_days <= 730)
    error_message = "Retention must be between 7 and 730 days."
  }
}

variable "daily_quota_gb" {
  description = "The workspace daily quota for ingestion in GB. Defaults to -1 (unlimited)."
  type        = number
  default     = -1
}

variable "internet_ingestion_enabled" {
  description = "Should the Log Analytics Workspace support ingestion over the Public Internet? Defaults to true."
  type        = bool
  default     = true
}

variable "internet_query_enabled" {
  description = "Should the Log Analytics Workspace support querying over the Public Internet? Defaults to true."
  type        = bool
  default     = true
}

variable "reservation_capacity_in_gb_per_day" {
  description = "The capacity reservation level in GB per day. Only valid when sku is CapacityReservation. Must be in increments of 100 between 100 and 5000."
  type        = number
  default     = null

  validation {
    condition = var.reservation_capacity_in_gb_per_day == null || (
      var.reservation_capacity_in_gb_per_day >= 100 &&
      var.reservation_capacity_in_gb_per_day <= 5000 &&
      var.reservation_capacity_in_gb_per_day % 100 == 0
    )
    error_message = "Reservation capacity must be in increments of 100 between 100 and 5000."
  }
}

variable "local_authentication_disabled" {
  description = "Specifies if the log analytics workspace should enforce authentication using Azure AD. Defaults to false."
  type        = bool
  default     = false
}

variable "cmk_for_query_forced" {
  description = "Is Customer Managed Storage mandatory for query management? Defaults to false."
  type        = bool
  default     = false
}

variable "identity_type" {
  description = "The type of Managed Identity which should be assigned to the Log Analytics Workspace. Possible values are SystemAssigned, UserAssigned."
  type        = string
  default     = null

  validation {
    condition     = var.identity_type == null || contains(["SystemAssigned", "UserAssigned", "SystemAssigned, UserAssigned"], var.identity_type)
    error_message = "Identity type must be SystemAssigned, UserAssigned, or SystemAssigned, UserAssigned."
  }
}

variable "identity_ids" {
  description = "A list of User Assigned Managed Identity IDs to be assigned to this Log Analytics Workspace. Required when identity_type is UserAssigned."
  type        = list(string)
  default     = []
}

variable "immediate_data_purge_on_30_days_enabled" {
  description = "Whether to remove the data in the Log Analytics Workspace immediately after 30 days. Defaults to false."
  type        = bool
  default     = false
}

variable "solutions" {
  description = "Map of Log Analytics solutions to deploy. Key is solution name, value is publisher."
  type = map(object({
    publisher = string
    product   = string
  }))
  default = {}
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  type        = map(string)
  default     = {}
}
