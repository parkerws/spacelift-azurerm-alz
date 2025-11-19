variable "name" {
  description = "The name or ID for this Management Group. This must be unique across your entire Azure AD tenant. Changing this forces a new resource to be created."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9_().-]{1,90}$", var.name))
    error_message = "Management Group name must be 1-90 characters and contain only alphanumerics, underscores, hyphens, periods, or parentheses."
  }
}

variable "display_name" {
  description = "A friendly name for this Management Group. If not specified, this will default to the name."
  type        = string
  default     = null
}

variable "parent_management_group_id" {
  description = "The ID of the parent Management Group. Changing this forces a new resource to be created. If not specified, the Management Group will be created at the root level."
  type        = string
  default     = null
}

variable "subscription_ids" {
  description = "A list of Subscription IDs to associate with the Management Group."
  type        = list(string)
  default     = []
}
