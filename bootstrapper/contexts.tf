# Spacelift Contexts for Azure Authentication
# Contexts store credentials and configuration that can be attached to stacks

# Azure Environment Context (shared across all stacks)
resource "spacelift_context" "azure_environment" {
  name        = "azure-environment-${var.organization_name}"
  description = "Azure environment configuration for ${var.organization_name}"
  space_id    = "root"

  labels = [
    "environment:azure",
    "type:configuration",
    "managed-by:terraform"
  ]
}

resource "spacelift_environment_variable" "azure_tenant_id" {
  context_id = spacelift_context.azure_environment.id
  name       = "ARM_TENANT_ID"
  value      = var.azure_tenant_id
  write_only = false
}

resource "spacelift_environment_variable" "azure_environment" {
  context_id = spacelift_context.azure_environment.id
  name       = "ARM_ENVIRONMENT"
  value      = var.azure_environment
  write_only = false
}

# Service Principal Contexts (one per environment)
resource "spacelift_context" "service_principals" {
  for_each = var.create_service_principals ? var.service_principal_names : {}

  name        = "azure-sp-${each.key}"
  description = "Azure service principal credentials for ${each.key} environment"
  space_id    = try(local.space_ids[each.key], "root")

  labels = [
    "environment:${each.key}",
    "type:credentials",
    "managed-by:terraform"
  ]

  depends_on = [
    spacelift_space.root_level,
    spacelift_space.platform_level,
    spacelift_space.landing_zone_level
  ]
}

resource "spacelift_environment_variable" "sp_subscription_id" {
  for_each = var.create_service_principals ? var.service_principal_names : {}

  context_id = spacelift_context.service_principals[each.key].id
  name       = "ARM_SUBSCRIPTION_ID"
  value      = var.azure_subscription_id
  write_only = false
}

resource "spacelift_environment_variable" "sp_client_id" {
  for_each = var.create_service_principals ? var.service_principal_names : {}

  context_id = spacelift_context.service_principals[each.key].id
  name       = "ARM_CLIENT_ID"
  value      = azuread_service_principal.spacelift[each.key].client_id
  write_only = false
}

resource "spacelift_environment_variable" "sp_client_secret" {
  for_each = var.create_service_principals ? var.service_principal_names : {}

  context_id = spacelift_context.service_principals[each.key].id
  name       = "ARM_CLIENT_SECRET"
  value      = azuread_application_password.spacelift[each.key].value
  write_only = true
}

# Module Registry Context
resource "spacelift_context" "module_registry" {
  name        = "module-registry-${var.organization_name}"
  description = "Configuration for module registry and versioning"
  space_id    = "root"

  labels = [
    "type:configuration",
    "purpose:module-registry",
    "managed-by:terraform"
  ]
}

resource "spacelift_environment_variable" "module_registry_enabled" {
  context_id = spacelift_context.module_registry.id
  name       = "TF_REGISTRY_MODULE_ENABLED"
  value      = "true"
  write_only = false
}

# Locals for context outputs
locals {
  contexts = {
    azure_environment = spacelift_context.azure_environment.id
    module_registry   = spacelift_context.module_registry.id
    service_principals = {
      for key, ctx in spacelift_context.service_principals :
      key => ctx.id
    }
  }
}
