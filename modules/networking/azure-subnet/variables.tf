variable "name" {
  description = "The name of the subnet. Changing this forces a new resource to be created."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-._]{0,78}[a-zA-Z0-9_]$", var.name))
    error_message = "The subnet name must be between 2 and 80 characters long, start with a letter or number, end with a letter, number or underscore, and may contain only letters, numbers, underscores, periods, and hyphens."
  }
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the subnet. Changing this forces a new resource to be created."
  type        = string
}

variable "virtual_network_name" {
  description = "The name of the virtual network to which to attach the subnet. Changing this forces a new resource to be created."
  type        = string
}

variable "address_prefixes" {
  description = "The address prefixes to use for the subnet. Each subnet must have a unique address prefix within the virtual network."
  type        = list(string)

  validation {
    condition     = length(var.address_prefixes) > 0
    error_message = "At least one address prefix must be provided."
  }
}

variable "default_outbound_access_enabled" {
  description = "Enable default outbound access to the internet for the subnet. Defaults to true. Set to false to disable default outbound internet access."
  type        = bool
  default     = true
}

variable "delegations" {
  description = "One or more delegation blocks for subnet delegation to Azure services. Each delegation requires a unique name and service delegation details."
  type = list(object({
    name = string
    service_delegation = object({
      name    = string
      actions = optional(list(string))
    })
  }))
  default = []
}

variable "private_endpoint_network_policies" {
  description = "Enable or disable network policies for private endpoints on the subnet. Possible values are Disabled, Enabled, NetworkSecurityGroupEnabled, and RouteTableEnabled. Defaults to Disabled."
  type        = string
  default     = "Disabled"

  validation {
    condition     = contains(["Disabled", "Enabled", "NetworkSecurityGroupEnabled", "RouteTableEnabled"], var.private_endpoint_network_policies)
    error_message = "Private endpoint network policies must be one of: Disabled, Enabled, NetworkSecurityGroupEnabled, RouteTableEnabled."
  }
}

variable "private_link_service_network_policies_enabled" {
  description = "Enable or disable network policies for the private link service on the subnet. Defaults to true."
  type        = bool
  default     = true
}

variable "service_endpoints" {
  description = "The list of Service endpoints to associate with the subnet. Possible values include: Microsoft.AzureActiveDirectory, Microsoft.AzureCosmosDB, Microsoft.ContainerRegistry, Microsoft.EventHub, Microsoft.KeyVault, Microsoft.ServiceBus, Microsoft.Sql, Microsoft.Storage, Microsoft.Storage.Global, and Microsoft.Web."
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for se in var.service_endpoints :
      contains([
        "Microsoft.AzureActiveDirectory",
        "Microsoft.AzureCosmosDB",
        "Microsoft.ContainerRegistry",
        "Microsoft.EventHub",
        "Microsoft.KeyVault",
        "Microsoft.ServiceBus",
        "Microsoft.Sql",
        "Microsoft.Storage",
        "Microsoft.Storage.Global",
        "Microsoft.Web"
      ], se)
    ])
    error_message = "Invalid service endpoint. Must be one of: Microsoft.AzureActiveDirectory, Microsoft.AzureCosmosDB, Microsoft.ContainerRegistry, Microsoft.EventHub, Microsoft.KeyVault, Microsoft.ServiceBus, Microsoft.Sql, Microsoft.Storage, Microsoft.Storage.Global, Microsoft.Web."
  }
}

variable "service_endpoint_policy_ids" {
  description = "The list of IDs of Service Endpoint Policies to associate with the subnet."
  type        = list(string)
  default     = []
}
