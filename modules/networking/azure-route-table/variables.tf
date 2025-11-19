variable "name" {
  description = "The name of the route table. Changing this forces a new resource to be created."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-._]{0,78}[a-zA-Z0-9_]$", var.name))
    error_message = "The route table name must be between 2 and 80 characters long, start with a letter or number, end with a letter, number or underscore, and may contain only letters, numbers, underscores, periods, and hyphens."
  }
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the route table. Changing this forces a new resource to be created."
  type        = string
}

variable "location" {
  description = "The location/region where the route table is created. Changing this forces a new resource to be created."
  type        = string
}

variable "disable_bgp_route_propagation" {
  description = "Boolean flag which controls propagation of routes learned by BGP on that route table. Defaults to false."
  type        = bool
  default     = false
}

variable "routes" {
  description = "List of routes to create. Routes are created as separate resources for better flexibility."
  type = list(object({
    name                   = string
    address_prefix         = string
    next_hop_type          = string
    next_hop_in_ip_address = optional(string)
  }))
  default = []

  validation {
    condition = alltrue([
      for route in var.routes :
      contains(["VirtualNetworkGateway", "VNetLocal", "Internet", "VirtualAppliance", "None"], route.next_hop_type)
    ])
    error_message = "Next hop type must be one of: VirtualNetworkGateway, VNetLocal, Internet, VirtualAppliance, None."
  }

  validation {
    condition = alltrue([
      for route in var.routes :
      route.next_hop_type != "VirtualAppliance" || route.next_hop_in_ip_address != null
    ])
    error_message = "Next hop IP address is required when next hop type is VirtualAppliance."
  }

  validation {
    condition = alltrue([
      for route in var.routes :
      can(cidrhost(route.address_prefix, 0))
    ])
    error_message = "Address prefix must be a valid CIDR notation."
  }
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  type        = map(string)
  default     = {}
}
