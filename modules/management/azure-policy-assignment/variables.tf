variable "name" {
  description = "The name which should be used for this Policy Assignment. Changing this forces a new Policy Assignment to be created."
  type        = string
  validation {
    condition     = length(var.name) <= 64
    error_message = "Policy Assignment name must be 64 characters or less."
  }
}

variable "display_name" {
  description = "The display name of this Policy Assignment. If not specified, defaults to the name."
  type        = string
  default     = null
}

variable "description" {
  description = "A description which should be used for this Policy Assignment."
  type        = string
  default     = null
}

variable "policy_definition_id" {
  description = "The ID of the Policy Definition or Policy Definition Set (Initiative) to assign."
  type        = string
}

variable "scope" {
  description = "The scope at which the Policy Assignment should be created. This can be a management group, subscription, or resource group ID."
  type        = string
}

variable "not_scopes" {
  description = "A list of scope resource IDs to exclude from this Policy Assignment."
  type        = list(string)
  default     = []
}

variable "enforcement_mode" {
  description = "The enforcement mode of the Policy Assignment. Possible values are Default and DoNotEnforce. Defaults to Default."
  type        = string
  default     = "Default"
  validation {
    condition     = contains(["Default", "DoNotEnforce"], var.enforcement_mode)
    error_message = "Enforcement mode must be Default or DoNotEnforce."
  }
}

variable "parameters" {
  description = "A JSON string containing the parameter values for the Policy Definition."
  type        = string
  default     = null
}

variable "metadata" {
  description = "A JSON string containing additional metadata for the Policy Assignment."
  type        = string
  default     = null
}

variable "identity" {
  description = "Identity configuration for policies with deployIfNotExists or modify effects."
  type = object({
    type         = string
    identity_ids = optional(list(string), [])
  })
  default = null
  validation {
    condition = var.identity == null || (
      contains(["SystemAssigned", "UserAssigned"], var.identity.type)
    )
    error_message = "Identity type must be SystemAssigned or UserAssigned."
  }
}

variable "location" {
  description = "The Azure location where the Policy Assignment should exist. Required when an identity is used."
  type        = string
  default     = null
}

variable "non_compliance_messages" {
  description = "One or more non-compliance messages for this Policy Assignment."
  type = list(object({
    content                        = string
    policy_definition_reference_id = optional(string, null)
  }))
  default = []
}

variable "resource_selectors" {
  description = "Resource selectors to filter which resources are evaluated by the policy."
  type = list(object({
    name = string
    selectors = list(object({
      kind   = string
      in     = optional(list(string), [])
      not_in = optional(list(string), [])
    }))
  }))
  default = []
}

variable "overrides" {
  description = "Policy assignment overrides for nested policies in an initiative."
  type = list(object({
    value = string
    selectors = optional(list(object({
      kind   = string
      in     = optional(list(string), [])
      not_in = optional(list(string), [])
    })), [])
  }))
  default = []
}
