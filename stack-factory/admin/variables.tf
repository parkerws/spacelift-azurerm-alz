variable "stacks_config_file" {
  description = "Path to the stacks configuration YAML file"
  type        = string
  default     = "../stacks.yaml"
}

variable "repository" {
  description = "GitHub/GitLab repository name"
  type        = string
}

variable "repository_namespace" {
  description = "GitHub/GitLab organization or user"
  type        = string
}

variable "repository_branch" {
  description = "Default branch for stacks"
  type        = string
  default     = "main"
}

variable "space_ids" {
  description = "Map of space IDs from bootstrapper"
  type        = map(string)
}

variable "context_ids" {
  description = "Map of context IDs from bootstrapper"
  type        = map(string)
}

variable "policy_ids" {
  description = "Map of policy IDs for attachment"
  type        = map(string)
  default     = {}
}

variable "worker_pool_id" {
  description = "Spacelift worker pool ID (optional)"
  type        = string
  default     = null
}

variable "terraform_version" {
  description = "Default Terraform version for stacks"
  type        = string
  default     = "1.8.0"
}

variable "azure_tenant_id" {
  description = "Azure AD Tenant ID"
  type        = string
}

variable "azure_subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}
