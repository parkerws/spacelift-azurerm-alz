variable "github_organization" {
  description = "GitHub organization name"
  type        = string
}

variable "github_repository" {
  description = "GitHub repository name (without org prefix)"
  type        = string
}

variable "azure_tenant_id" {
  description = "Azure AD Tenant ID"
  type        = string
}

variable "azure_subscription_id" {
  description = "Azure Subscription ID for landing zones"
  type        = string
}

variable "create_service_principals" {
  description = "Whether to create Azure service principals"
  type        = bool
  default     = true
}

variable "use_oidc" {
  description = "Use OIDC federation instead of client secrets"
  type        = bool
  default     = true
}

variable "environments" {
  description = "GitHub environments to create"
  type = map(object({
    wait_timer          = optional(number, 0)
    reviewers           = optional(list(string), [])
    deployment_branch_policy = optional(string, "all") # all, protected, or custom
  }))
  default = {
    production = {
      wait_timer          = 0
      reviewers           = [] # Add GitHub usernames or team slugs
      deployment_branch_policy = "protected"
    }
    staging = {
      wait_timer          = 0
      deployment_branch_policy = "all"
    }
    development = {
      wait_timer          = 0
      deployment_branch_policy = "all"
    }
  }
}

variable "enable_branch_protection" {
  description = "Enable branch protection rules"
  type        = bool
  default     = true
}

variable "protected_branches" {
  description = "Branches to protect"
  type        = list(string)
  default     = ["main"]
}

variable "required_approvals" {
  description = "Number of required approvals for production"
  type        = number
  default     = 2
}

variable "create_terraform_state_storage" {
  description = "Create Azure Storage for Terraform state"
  type        = bool
  default     = true
}

variable "state_storage_location" {
  description = "Location for Terraform state storage"
  type        = string
  default     = "eastus"
}

variable "enable_self_hosted_runners" {
  description = "Enable self-hosted runner configuration"
  type        = bool
  default     = false
}

variable "runner_labels" {
  description = "Labels for self-hosted runners"
  type        = list(string)
  default     = ["azure", "terraform"]
}

variable "tags" {
  description = "Common tags for Azure resources"
  type        = map(string)
  default = {
    ManagedBy = "Terraform"
    Purpose   = "GitHub-Actions-Landing-Zone"
  }
}
