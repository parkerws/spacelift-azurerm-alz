variable "name" {
  description = "The name of the virtual network. Changing this forces a new resource to be created."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-._]{0,62}[a-zA-Z0-9_]$", var.name))
    error_message = "The virtual network name must be between 2 and 64 characters long, start with a letter or number, end with a letter, number or underscore, and may contain only letters, numbers, underscores, periods, and hyphens."
  }
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the virtual network. Changing this forces a new resource to be created."
  type        = string
}

variable "location" {
  description = "The location/region where the virtual network is created. Changing this forces a new resource to be created."
  type        = string
}

variable "address_space" {
  description = "The address space that is used by the virtual network. You can supply more than one address space."
  type        = list(string)

  validation {
    condition     = length(var.address_space) > 0
    error_message = "At least one address space must be provided."
  }
}

variable "bgp_community" {
  description = "The BGP community attribute in format <as-number>:<community-value>. The as-number segment is the Microsoft ASN, which is always 12076 for now."
  type        = string
  default     = null
}

variable "ddos_protection_plan" {
  description = "A DDoS protection plan configuration block. If enabled, a DDoS protection plan must be specified."
  type = object({
    id     = string
    enable = bool
  })
  default = null
}

variable "dns_servers" {
  description = "List of IP addresses of DNS servers. If no values are provided, the default Azure DNS will be used."
  type        = list(string)
  default     = []
}

variable "edge_zone" {
  description = "Specifies the Edge Zone within the Azure Region where this Virtual Network should exist. Changing this forces a new Virtual Network to be created."
  type        = string
  default     = null
}

variable "encryption" {
  description = "An encryption block to enable VNet encryption. Enforcement must be 'AllowUnencrypted' or 'DropUnencrypted'."
  type = object({
    enforcement = string
  })
  default = null

  validation {
    condition = var.encryption == null || (
      var.encryption != null &&
      contains(["AllowUnencrypted", "DropUnencrypted"], var.encryption.enforcement)
    )
    error_message = "Encryption enforcement must be either 'AllowUnencrypted' or 'DropUnencrypted'."
  }
}

variable "flow_timeout_in_minutes" {
  description = "The flow timeout in minutes for the Virtual Network, which is used to enable connection tracking for intra-VM flows. Possible values are between 4 and 30 minutes."
  type        = number
  default     = null

  validation {
    condition = var.flow_timeout_in_minutes == null || (
      var.flow_timeout_in_minutes >= 4 &&
      var.flow_timeout_in_minutes <= 30
    )
    error_message = "Flow timeout must be between 4 and 30 minutes."
  }
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  type        = map(string)
  default     = {}
}
