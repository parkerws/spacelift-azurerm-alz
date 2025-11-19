variable "name" {
  description = "The name of the virtual network peering. Changing this forces a new resource to be created."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-._]{0,78}[a-zA-Z0-9_]$", var.name))
    error_message = "The peering name must be between 2 and 80 characters long."
  }
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the virtual network peering. Changing this forces a new resource to be created."
  type        = string
}

variable "virtual_network_name" {
  description = "The name of the virtual network. Changing this forces a new resource to be created."
  type        = string
}

variable "remote_virtual_network_id" {
  description = "The full Azure resource ID of the remote virtual network. Changing this forces a new resource to be created."
  type        = string
}

variable "allow_virtual_network_access" {
  description = "Controls if the VMs in the remote virtual network can access VMs in the local virtual network. Defaults to true."
  type        = bool
  default     = true
}

variable "allow_forwarded_traffic" {
  description = "Controls if forwarded traffic from VMs in the remote virtual network is allowed. Defaults to false."
  type        = bool
  default     = false
}

variable "allow_gateway_transit" {
  description = "Controls gatewayLinks can be used in the remote virtual network's link to the local virtual network. Defaults to false."
  type        = bool
  default     = false
}

variable "use_remote_gateways" {
  description = "Controls if remote gateways can be used on the local virtual network. Defaults to false."
  type        = bool
  default     = false
}

variable "triggers" {
  description = "A mapping of trigger values which will cause the peering to be recreated."
  type        = map(string)
  default     = {}
}
