output "spacelift_account_name" {
  description = "The name of the Spacelift account"
  value       = data.spacelift_current_account.this.name
}

output "space_ids" {
  description = "Map of space names to their IDs"
  value       = local.space_ids
}

output "space_hierarchy" {
  description = "Complete space hierarchy structure"
  value = {
    root = {
      platform = {
        id   = spacelift_space.root_level["platform"].id
        name = spacelift_space.root_level["platform"].name
        children = {
          for key, space in spacelift_space.platform_level :
          key => {
            id   = space.id
            name = space.name
          }
        }
      }
      landing_zones = {
        id   = spacelift_space.root_level["landing_zones"].id
        name = spacelift_space.root_level["landing_zones"].name
        children = {
          for key, space in spacelift_space.landing_zone_level :
          key => {
            id   = space.id
            name = space.name
          }
        }
      }
    }
  }
}

output "service_principal_app_ids" {
  description = "Map of service principal application (client) IDs"
  value = var.create_service_principals ? {
    for key, sp in azuread_service_principal.spacelift :
    key => sp.client_id
  } : {}
}

output "service_principal_object_ids" {
  description = "Map of service principal object IDs"
  value = var.create_service_principals ? {
    for key, sp in azuread_service_principal.spacelift :
    key => sp.object_id
  } : {}
}

output "context_ids" {
  description = "Map of Spacelift context IDs"
  value       = local.contexts
}

output "azure_tenant_id" {
  description = "Azure AD Tenant ID"
  value       = var.azure_tenant_id
}

output "azure_subscription_id" {
  description = "Azure Subscription ID"
  value       = var.azure_subscription_id
}

# Sensitive outputs for service principal secrets
output "service_principal_credentials" {
  description = "Service principal credentials (sensitive)"
  value = var.create_service_principals ? {
    for key, sp in azuread_service_principal.spacelift :
    key => {
      client_id     = sp.client_id
      client_secret = azuread_application_password.spacelift[key].value
      tenant_id     = var.azure_tenant_id
    }
  } : {}
  sensitive = true
}

output "bootstrap_complete" {
  description = "Bootstrap completion status"
  value = {
    spaces_created              = length(local.all_spaces)
    service_principals_created  = var.create_service_principals ? length(azuread_service_principal.spacelift) : 0
    contexts_created            = 1 + length(spacelift_context.service_principals) + 1 # azure_env + SPs + module_registry
    ready_for_stack_deployment  = true
  }
}
