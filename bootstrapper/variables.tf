variable "organization_name" {
  description = "The name of your organization (used for naming resources)"
  type        = string
}

variable "azure_tenant_id" {
  description = "Azure AD Tenant ID"
  type        = string
}

variable "azure_subscription_id" {
  description = "Azure Subscription ID for the management subscription"
  type        = string
}

variable "create_service_principals" {
  description = "Whether to create Azure service principals for Spacelift"
  type        = bool
  default     = true
}

variable "service_principal_names" {
  description = "Map of service principal names for different environments"
  type        = map(string)
  default = {
    platform       = "sp-spacelift-platform"
    connectivity   = "sp-spacelift-connectivity"
    identity       = "sp-spacelift-identity"
    management     = "sp-spacelift-management"
    landing_zones  = "sp-spacelift-landing-zones"
  }
}

variable "spacelift_spaces" {
  description = "Configuration for Spacelift space hierarchy"
  type = map(object({
    name        = string
    description = string
    parent_id   = optional(string, "root")
    inherit_entities = optional(bool, true)
  }))
  default = {
    platform = {
      name        = "Platform"
      description = "Platform services and infrastructure"
      parent_id   = "root"
    }
    connectivity = {
      name        = "Connectivity"
      description = "Hub networking and connectivity resources"
      parent_id   = "platform"
    }
    identity = {
      name        = "Identity"
      description = "Identity and access management resources"
      parent_id   = "platform"
    }
    management = {
      name        = "Management"
      description = "Management and monitoring resources"
      parent_id   = "platform"
    }
    landing_zones = {
      name        = "Landing Zones"
      description = "Application landing zones"
      parent_id   = "root"
    }
    corp = {
      name        = "Corp"
      description = "Corporate landing zones with on-premises connectivity"
      parent_id   = "landing_zones"
    }
    online = {
      name        = "Online"
      description = "Online landing zones for internet-facing workloads"
      parent_id   = "landing_zones"
    }
  }
}

variable "github_repository" {
  description = "GitHub repository for the landing zone factory (format: owner/repo)"
  type        = string
  default     = null
}

variable "vcs_provider" {
  description = "VCS provider (github, gitlab, bitbucket, etc.)"
  type        = string
  default     = "github"
}

variable "azure_environment" {
  description = "Azure environment (public, usgovernment, china)"
  type        = string
  default     = "public"
  validation {
    condition     = contains(["public", "usgovernment", "china"], var.azure_environment)
    error_message = "Azure environment must be public, usgovernment, or china."
  }
}

variable "worker_pool_id" {
  description = "Spacelift worker pool ID (if using private workers)"
  type        = string
  default     = null
}

variable "tags" {
  description = "Common tags to apply to Azure resources"
  type        = map(string)
  default = {
    ManagedBy = "Spacelift"
    Purpose   = "Landing-Zone-Factory"
  }
}
