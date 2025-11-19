variable "name" {
  description = "The name of the Virtual Network Gateway. Changing this forces a new resource to be created."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-._]{0,78}[a-zA-Z0-9_]$", var.name))
    error_message = "The VPN gateway name must be between 2 and 80 characters long."
  }
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the Virtual Network Gateway. Changing this forces a new resource to be created."
  type        = string
}

variable "location" {
  description = "The location/region where the Virtual Network Gateway is created. Changing this forces a new resource to be created."
  type        = string
}

variable "type" {
  description = "The type of the Virtual Network Gateway. Valid options are Vpn or ExpressRoute. Changing this forces a new resource to be created."
  type        = string
  default     = "Vpn"

  validation {
    condition     = contains(["Vpn", "ExpressRoute"], var.type)
    error_message = "Type must be either Vpn or ExpressRoute."
  }
}

variable "vpn_type" {
  description = "The routing type of the Virtual Network Gateway. Valid options are RouteBased or PolicyBased. Defaults to RouteBased. Changing this forces a new resource to be created."
  type        = string
  default     = "RouteBased"

  validation {
    condition     = contains(["RouteBased", "PolicyBased"], var.vpn_type)
    error_message = "VPN type must be either RouteBased or PolicyBased."
  }
}

variable "sku" {
  description = "Configuration of the size and capacity of the VPN gateway. Valid options are Basic, Standard, HighPerformance, UltraPerformance, ErGw1AZ, ErGw2AZ, ErGw3AZ, VpnGw1, VpnGw2, VpnGw3, VpnGw4, VpnGw5, VpnGw1AZ, VpnGw2AZ, VpnGw3AZ, VpnGw4AZ, and VpnGw5AZ."
  type        = string
  default     = "VpnGw1"
}

variable "generation" {
  description = "The Generation of the Virtual Network gateway. Possible values are Generation1, Generation2, or None. Changing this forces a new resource to be created."
  type        = string
  default     = "Generation2"

  validation {
    condition     = contains(["Generation1", "Generation2", "None"], var.generation)
    error_message = "Generation must be Generation1, Generation2, or None."
  }
}

variable "enable_bgp" {
  description = "Enable BGP (Border Gateway Protocol) for this Virtual Network Gateway."
  type        = bool
  default     = false
}

variable "active_active" {
  description = "Enable active-active mode. An active-active VPN gateway has two gateway IP configurations and two public IP addresses."
  type        = bool
  default     = false
}

variable "private_ip_address_allocation" {
  description = "Defines how the private IP address of the gateways virtual interface is assigned. Valid options are Static or Dynamic. Defaults to Dynamic."
  type        = string
  default     = "Dynamic"

  validation {
    condition     = contains(["Static", "Dynamic"], var.private_ip_address_allocation)
    error_message = "Private IP address allocation must be either Static or Dynamic."
  }
}

variable "default_local_network_gateway_id" {
  description = "The ID of the local network gateway through which outbound Internet traffic from the VPN will be routed (forced tunneling)."
  type        = string
  default     = null
}

variable "subnet_id" {
  description = "The ID of the GatewaySubnet. Changing this forces a new resource to be created."
  type        = string
}

variable "public_ip_address_ids" {
  description = "List of public IP address IDs to associate with the VPN gateway. Provide 2 IPs for active-active mode."
  type        = list(string)
  default     = []
}

variable "create_public_ips" {
  description = "Whether to create public IP addresses automatically. Set to false if providing public_ip_address_ids."
  type        = bool
  default     = true
}

variable "public_ip_allocation_method" {
  description = "Allocation method for the public IP. Must be Static for VPN gateway. Azure allocates IPs differently in different regions."
  type        = string
  default     = "Static"

  validation {
    condition     = var.public_ip_allocation_method == "Static" || var.public_ip_allocation_method == "Dynamic"
    error_message = "Public IP allocation method must be Static or Dynamic."
  }
}

variable "public_ip_sku" {
  description = "The SKU of the Public IP. Must be Standard for zone-redundant gateways."
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Basic", "Standard"], var.public_ip_sku)
    error_message = "Public IP SKU must be Basic or Standard."
  }
}

variable "bgp_settings" {
  description = "BGP settings block. Required when enable_bgp is true."
  type = object({
    asn             = number
    peering_address = optional(string)
    peer_weight     = optional(number)
  })
  default = null
}

variable "vpn_client_configuration" {
  description = "Configuration for point-to-site VPN clients."
  type = object({
    address_space         = list(string)
    vpn_client_protocols  = optional(list(string), ["OpenVPN"])
    aad_tenant            = optional(string)
    aad_audience          = optional(string)
    aad_issuer            = optional(string)
    root_certificate      = optional(list(object({
      name             = string
      public_cert_data = string
    })), [])
    revoked_certificate   = optional(list(object({
      name       = string
      thumbprint = string
    })), [])
    radius_server_address = optional(string)
    radius_server_secret  = optional(string)
    vpn_auth_types        = optional(list(string))
  })
  default = null
}

variable "custom_route" {
  description = "Custom routes to advertise to BGP peers."
  type = object({
    address_prefixes = list(string)
  })
  default = null
}

variable "edge_zone" {
  description = "Specifies the Edge Zone within the Azure Region where this Virtual Network Gateway should exist. Changing this forces a new resource to be created."
  type        = string
  default     = null
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  type        = map(string)
  default     = {}
}
