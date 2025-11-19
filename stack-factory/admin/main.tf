provider "spacelift" {
  # Configure using environment variables:
  # SPACELIFT_API_KEY_ENDPOINT
  # SPACELIFT_API_KEY_ID
  # SPACELIFT_API_KEY_SECRET
}

# Local module to convert YAML to objects
locals {
  # In production, use yamldecode() with file content
  # For now, using map-based configuration

  # Example hub configurations
  hub_stacks = {
    "hub-connectivity-prod" = {
      name        = "hub-connectivity-prod"
      space_id    = lookup(var.space_ids, "connectivity", var.space_ids["platform"])
      environment = "production"
      location    = "eastus"
      description = "Production hub network with connectivity services"
      labels      = ["production", "hub", "connectivity", "eastus"]
      project_root = "stack-factory/hub"
    }
  }

  # Example spoke configurations
  spoke_stacks = {
    "spoke-corp-prod-001" = {
      name        = "spoke-corp-prod-001"
      space_id    = lookup(var.space_ids, "corp", var.space_ids["landing_zones"])
      environment = "production"
      location    = "eastus"
      description = "Corporate workload landing zone - Production 001"
      labels      = ["production", "spoke", "corp", "eastus"]
      hub_stack   = "hub-connectivity-prod"
      project_root = "stack-factory/spoke"
    }
    "spoke-online-prod-001" = {
      name        = "spoke-online-prod-001"
      space_id    = lookup(var.space_ids, "online", var.space_ids["landing_zones"])
      environment = "production"
      location    = "eastus"
      description = "Online workload landing zone - Production 001"
      labels      = ["production", "spoke", "online", "eastus"]
      hub_stack   = "hub-connectivity-prod"
      project_root = "stack-factory/spoke"
    }
  }
}

# Create hub stacks
resource "spacelift_stack" "hub" {
  for_each = local.hub_stacks

  name         = each.value.name
  space_id     = each.value.space_id
  description  = each.value.description
  project_root = each.value.project_root

  # VCS configuration
  repository   = var.repository
  namespace    = var.repository_namespace
  branch       = var.repository_branch

  # Terraform configuration
  terraform_version    = var.terraform_version
  administrative       = false
  autodeploy           = false  # Require manual confirmation for production
  enable_local_preview = true

  # Worker pool
  worker_pool_id = var.worker_pool_id

  # Labels for policy and context attachment
  labels = each.value.labels
}

# Create spoke stacks with hub dependencies
resource "spacelift_stack" "spoke" {
  for_each = local.spoke_stacks

  name         = each.value.name
  space_id     = each.value.space_id
  description  = each.value.description
  project_root = each.value.project_root

  # VCS configuration
  repository   = var.repository
  namespace    = var.repository_namespace
  branch       = var.repository_branch

  # Terraform configuration
  terraform_version    = var.terraform_version
  administrative       = false
  autodeploy           = false
  enable_local_preview = true

  # Worker pool
  worker_pool_id = var.worker_pool_id

  # Labels
  labels = each.value.labels
}

# Hub to spoke dependencies
resource "spacelift_stack_dependency" "spoke_to_hub" {
  for_each = {
    for k, v in local.spoke_stacks : k => v
    if v.hub_stack != null
  }

  stack_id            = spacelift_stack.spoke[each.key].id
  depends_on_stack_id = spacelift_stack.hub[each.value.hub_stack].id
}

# Attach Azure contexts to hub stacks
resource "spacelift_context_attachment" "hub_azure" {
  for_each = local.hub_stacks

  context_id = lookup(var.context_ids, "azure_sp_connectivity", var.context_ids["azure_environment"])
  stack_id   = spacelift_stack.hub[each.key].id
  priority   = 1
}

# Attach Azure contexts to spoke stacks
resource "spacelift_context_attachment" "spoke_azure" {
  for_each = local.spoke_stacks

  context_id = lookup(var.context_ids, "azure_sp_landing_zones", var.context_ids["azure_environment"])
  stack_id   = spacelift_stack.spoke[each.key].id
  priority   = 1
}

# Attach production approval policy to production stacks
resource "spacelift_policy_attachment" "hub_production_approval" {
  for_each = {
    for k, v in local.hub_stacks : k => v
    if v.environment == "production" && contains(keys(var.policy_ids), "production_approval")
  }

  policy_id = var.policy_ids["production_approval"]
  stack_id  = spacelift_stack.hub[each.key].id
}

resource "spacelift_policy_attachment" "spoke_production_approval" {
  for_each = {
    for k, v in local.spoke_stacks : k => v
    if v.environment == "production" && contains(keys(var.policy_ids), "production_approval")
  }

  policy_id = var.policy_ids["production_approval"]
  stack_id  = spacelift_stack.spoke[each.key].id
}

# Set stack environment variables
resource "spacelift_environment_variable" "hub_location" {
  for_each = local.hub_stacks

  stack_id   = spacelift_stack.hub[each.key].id
  name       = "TF_VAR_location"
  value      = each.value.location
  write_only = false
}

resource "spacelift_environment_variable" "hub_environment" {
  for_each = local.hub_stacks

  stack_id   = spacelift_stack.hub[each.key].id
  name       = "TF_VAR_environment"
  value      = each.value.environment
  write_only = false
}

resource "spacelift_environment_variable" "spoke_location" {
  for_each = local.spoke_stacks

  stack_id   = spacelift_stack.spoke[each.key].id
  name       = "TF_VAR_location"
  value      = each.value.location
  write_only = false
}

resource "spacelift_environment_variable" "spoke_environment" {
  for_each = local.spoke_stacks

  stack_id   = spacelift_stack.spoke[each.key].id
  name       = "TF_VAR_environment"
  value      = each.value.environment
  write_only = false
}
