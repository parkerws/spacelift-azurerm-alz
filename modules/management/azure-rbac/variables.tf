variable "scope" {
  description = "The scope at which the Role Assignment applies. This can be a management group, subscription, resource group, or resource ID."
  type        = string
}

variable "role_definition_name" {
  description = "The name of a built-in Role Definition. Conflicts with role_definition_id."
  type        = string
  default     = null
}

variable "role_definition_id" {
  description = "The ID of a custom Role Definition. Conflicts with role_definition_name."
  type        = string
  default     = null
}

variable "principal_id" {
  description = "The ID of the Principal (User, Group, or Service Principal) to assign the Role to."
  type        = string
}

variable "principal_type" {
  description = "The type of principal. Possible values are User, Group, ServicePrincipal, ForeignGroup, and Device. Only used for informational purposes."
  type        = string
  default     = null
  validation {
    condition = var.principal_type == null || (
      contains(["User", "Group", "ServicePrincipal", "ForeignGroup", "Device"], var.principal_type)
    )
    error_message = "Principal type must be one of: User, Group, ServicePrincipal, ForeignGroup, Device."
  }
}

variable "condition" {
  description = "The condition that limits the resources that the role can be assigned to."
  type        = string
  default     = null
}

variable "condition_version" {
  description = "The version of the condition syntax. If condition is specified, this must be set. Possible values are 1.0 or 2.0."
  type        = string
  default     = null
  validation {
    condition = var.condition_version == null || (
      contains(["1.0", "2.0"], var.condition_version)
    )
    error_message = "Condition version must be 1.0 or 2.0."
  }
}

variable "delegated_managed_identity_resource_id" {
  description = "The delegated Azure Resource ID which contains a Managed Identity."
  type        = string
  default     = null
}

variable "description" {
  description = "The description for this Role Assignment."
  type        = string
  default     = null
}

variable "skip_service_principal_aad_check" {
  description = "If set to true, skip the Azure Active Directory check for the service principal existence. This can be useful when assigning roles to service principals that may not be fully replicated yet."
  type        = bool
  default     = false
}
