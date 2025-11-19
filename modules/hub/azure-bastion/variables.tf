variable "name" {
  description = "The name of the Bastion Host. Changing this forces a new resource to be created."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-._]{0,78}[a-zA-Z0-9_]$", var.name))
    error_message = "The Bastion Host name must be between 2 and 80 characters long."
  }
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the Bastion Host. Changing this forces a new resource to be created."
  type        = string
}

variable "location" {
  description = "The location/region where the Bastion Host is created. Changing this forces a new resource to be created."
  type        = string
}

variable "sku" {
  description = "The SKU of the Bastion Host. Accepted values are Basic, Standard, and Premium. Defaults to Standard."
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku)
    error_message = "SKU must be Basic, Standard, or Premium."
  }
}

variable "scale_units" {
  description = "The number of scale units with which to provision the Bastion Host. Possible values are between 2 and 50. Defaults to 2. Only applicable when sku is Standard or Premium."
  type        = number
  default     = 2

  validation {
    condition     = var.scale_units >= 2 && var.scale_units <= 50
    error_message = "Scale units must be between 2 and 50."
  }
}

variable "subnet_id" {
  description = "The ID of the AzureBastionSubnet. Changing this forces a new resource to be created."
  type        = string
}

variable "public_ip_address_id" {
  description = "The ID of the public IP address to associate with the Bastion Host. If not provided, a public IP will be created."
  type        = string
  default     = null
}

variable "create_public_ip" {
  description = "Whether to create a public IP address. Set to false if providing public_ip_address_id."
  type        = bool
  default     = true
}

variable "public_ip_allocation_method" {
  description = "The allocation method for the public IP. Must be Static for Bastion."
  type        = string
  default     = "Static"

  validation {
    condition     = var.public_ip_allocation_method == "Static"
    error_message = "Public IP allocation method must be Static for Azure Bastion."
  }
}

variable "public_ip_sku" {
  description = "The SKU of the Public IP. Must be Standard for Bastion."
  type        = string
  default     = "Standard"

  validation {
    condition     = var.public_ip_sku == "Standard"
    error_message = "Public IP SKU must be Standard for Azure Bastion."
  }
}

variable "copy_paste_enabled" {
  description = "Is copy/paste feature enabled for the Bastion Host. Defaults to true."
  type        = bool
  default     = true
}

variable "file_copy_enabled" {
  description = "Is file copy feature enabled for the Bastion Host. Only applicable when sku is Standard or Premium. Defaults to false."
  type        = bool
  default     = false
}

variable "ip_connect_enabled" {
  description = "Is IP connect feature enabled for the Bastion Host. Only applicable when sku is Standard or Premium. Defaults to false."
  type        = bool
  default     = false
}

variable "shareable_link_enabled" {
  description = "Is shareable link feature enabled for the Bastion Host. Only applicable when sku is Standard or Premium. Defaults to false."
  type        = bool
  default     = false
}

variable "tunneling_enabled" {
  description = "Is tunneling feature enabled for the Bastion Host. Only applicable when sku is Standard or Premium. Defaults to false."
  type        = bool
  default     = false
}

variable "kerberos_enabled" {
  description = "Is Kerberos authentication enabled for the Bastion Host. Only applicable when sku is Standard or Premium. Defaults to false."
  type        = bool
  default     = false
}

variable "zones" {
  description = "Availability zones in which the Bastion Host should be created. Only applicable when sku is Standard or Premium."
  type        = list(string)
  default     = null

  validation {
    condition = var.zones == null || alltrue([
      for zone in var.zones :
      contains(["1", "2", "3"], zone)
    ])
    error_message = "Zones must be 1, 2, or 3."
  }
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  type        = map(string)
  default     = {}
}
