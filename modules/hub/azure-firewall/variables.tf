variable "name" {
  description = "The name of the Azure Firewall. Changing this forces a new resource to be created."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-._]{0,78}[a-zA-Z0-9_]$", var.name))
    error_message = "The firewall name must be between 2 and 80 characters long, start with a letter or number, end with a letter, number or underscore, and may contain only letters, numbers, underscores, periods, and hyphens."
  }
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the Azure Firewall. Changing this forces a new resource to be created."
  type        = string
}

variable "location" {
  description = "The location/region where the Azure Firewall is created. Changing this forces a new resource to be created."
  type        = string
}

variable "sku_name" {
  description = "SKU name of the Firewall. Possible values are AZFW_Hub and AZFW_VNet. Changing this forces a new resource to be created."
  type        = string
  default     = "AZFW_VNet"

  validation {
    condition     = contains(["AZFW_Hub", "AZFW_VNet"], var.sku_name)
    error_message = "SKU name must be either AZFW_Hub or AZFW_VNet."
  }
}

variable "sku_tier" {
  description = "SKU tier of the Firewall. Possible values are Premium, Standard, and Basic."
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Premium", "Standard", "Basic"], var.sku_tier)
    error_message = "SKU tier must be either Premium, Standard, or Basic."
  }
}

variable "firewall_policy_id" {
  description = "The ID of the Firewall Policy applied to this Firewall. Required when sku_tier is Premium or Standard."
  type        = string
  default     = null
}

variable "ip_configurations" {
  description = "List of IP configurations for the firewall. At least one is required. First IP configuration is primary."
  type = list(object({
    name                 = string
    subnet_id            = optional(string)
    public_ip_address_id = string
  }))
  default = []

  validation {
    condition     = length(var.ip_configurations) <= 100
    error_message = "Maximum of 100 IP configurations allowed."
  }
}

variable "management_ip_configuration" {
  description = "Management IP configuration for forced tunneling. Required when sku_tier is Basic or when configuring forced tunneling."
  type = object({
    name                 = string
    subnet_id            = string
    public_ip_address_id = string
  })
  default = null
}

variable "virtual_hub_id" {
  description = "The ID of the Virtual Hub where the Firewall should be created. Used with AZFW_Hub SKU only."
  type        = string
  default     = null
}

variable "public_ip_count" {
  description = "Number of public IPs to create and associate with the firewall. Only used when ip_configurations is not provided. Range: 1-100."
  type        = number
  default     = 1

  validation {
    condition     = var.public_ip_count >= 1 && var.public_ip_count <= 100
    error_message = "Public IP count must be between 1 and 100."
  }
}

variable "dns_servers" {
  description = "List of DNS servers that the Azure Firewall will direct DNS traffic to for name resolution."
  type        = list(string)
  default     = []
}

variable "dns_proxy_enabled" {
  description = "Whether DNS proxy is enabled. When enabled, the firewall acts as a DNS proxy."
  type        = bool
  default     = false
}

variable "threat_intel_mode" {
  description = "The operation mode for threat intelligence-based filtering. Possible values are Alert, Deny, and Off. Defaults to Alert."
  type        = string
  default     = "Alert"

  validation {
    condition     = contains(["Alert", "Deny", "Off"], var.threat_intel_mode)
    error_message = "Threat intelligence mode must be Alert, Deny, or Off."
  }
}

variable "zones" {
  description = "Availability zones in which the Azure Firewall should be created. Possible values are 1, 2, and 3."
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

variable "private_ip_ranges" {
  description = "List of SNAT private IP ranges. When configured, Azure Firewall will not SNAT traffic to these ranges."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  type        = map(string)
  default     = {}
}

# Public IP variables (used when creating PIPs automatically)
variable "public_ip_prefix_id" {
  description = "The ID of the Public IP Prefix from which to allocate public IPs."
  type        = string
  default     = null
}

variable "public_ip_sku" {
  description = "The SKU of the Public IP. Must be Standard for Azure Firewall."
  type        = string
  default     = "Standard"

  validation {
    condition     = var.public_ip_sku == "Standard"
    error_message = "Public IP SKU must be Standard for Azure Firewall."
  }
}

variable "public_ip_allocation_method" {
  description = "The allocation method for the Public IP. Must be Static for Azure Firewall."
  type        = string
  default     = "Static"

  validation {
    condition     = var.public_ip_allocation_method == "Static"
    error_message = "Public IP allocation method must be Static for Azure Firewall."
  }
}

variable "subnet_id" {
  description = "The ID of the AzureFirewallSubnet. Required when sku_name is AZFW_VNet and ip_configurations is not provided."
  type        = string
  default     = null
}
