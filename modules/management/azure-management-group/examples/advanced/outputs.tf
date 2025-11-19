output "root_id" {
  description = "The root management group ID"
  value       = module.mg_root.id
}

output "platform_id" {
  description = "The platform management group ID"
  value       = module.mg_platform.id
}

output "connectivity_id" {
  description = "The connectivity management group ID"
  value       = module.mg_connectivity.id
}

output "identity_id" {
  description = "The identity management group ID"
  value       = module.mg_identity.id
}

output "management_id" {
  description = "The management management group ID"
  value       = module.mg_management.id
}

output "landing_zones_id" {
  description = "The landing zones management group ID"
  value       = module.mg_landing_zones.id
}

output "corp_id" {
  description = "The corp management group ID"
  value       = module.mg_corp.id
}

output "online_id" {
  description = "The online management group ID"
  value       = module.mg_online.id
}

output "sandboxes_id" {
  description = "The sandboxes management group ID"
  value       = module.mg_sandboxes.id
}

output "decommissioned_id" {
  description = "The decommissioned management group ID"
  value       = module.mg_decommissioned.id
}

output "hierarchy" {
  description = "The complete management group hierarchy structure"
  value = {
    root = {
      id           = module.mg_root.id
      display_name = module.mg_root.display_name
      platform = {
        id           = module.mg_platform.id
        display_name = module.mg_platform.display_name
        connectivity = {
          id           = module.mg_connectivity.id
          display_name = module.mg_connectivity.display_name
        }
        identity = {
          id           = module.mg_identity.id
          display_name = module.mg_identity.display_name
        }
        management = {
          id           = module.mg_management.id
          display_name = module.mg_management.display_name
        }
      }
      landing_zones = {
        id           = module.mg_landing_zones.id
        display_name = module.mg_landing_zones.display_name
        corp = {
          id           = module.mg_corp.id
          display_name = module.mg_corp.display_name
        }
        online = {
          id           = module.mg_online.id
          display_name = module.mg_online.display_name
        }
      }
      sandboxes = {
        id           = module.mg_sandboxes.id
        display_name = module.mg_sandboxes.display_name
      }
      decommissioned = {
        id           = module.mg_decommissioned.id
        display_name = module.mg_decommissioned.display_name
      }
    }
  }
}
