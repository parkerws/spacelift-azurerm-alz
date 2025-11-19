# Spacelift Space Hierarchy
# Creates a hierarchical structure for organizing stacks

locals {
  # Build space dependency map
  space_map = {
    for key, config in var.spacelift_spaces :
    key => config.parent_id == "platform" ? "platform" :
    config.parent_id == "landing_zones" ? "landing_zones" :
    config.parent_id
  }

  # Spaces that depend on root
  root_spaces = {
    for key, config in var.spacelift_spaces :
    key => config if config.parent_id == "root"
  }

  # Spaces that depend on platform
  platform_spaces = {
    for key, config in var.spacelift_spaces :
    key => config if config.parent_id == "platform"
  }

  # Spaces that depend on landing_zones
  landing_zone_spaces = {
    for key, config in var.spacelift_spaces :
    key => config if config.parent_id == "landing_zones"
  }
}

# Root-level spaces (platform, landing_zones)
resource "spacelift_space" "root_level" {
  for_each = local.root_spaces

  name             = each.value.name
  description      = each.value.description
  parent_space_id  = "root"
  inherit_entities = each.value.inherit_entities

  labels = [
    "environment:${lower(each.key)}",
    "managed-by:terraform",
    "factory:azure-landing-zone"
  ]
}

# Platform child spaces (connectivity, identity, management)
resource "spacelift_space" "platform_level" {
  for_each = local.platform_spaces

  name             = each.value.name
  description      = each.value.description
  parent_space_id  = spacelift_space.root_level["platform"].id
  inherit_entities = each.value.inherit_entities

  labels = [
    "environment:${lower(each.key)}",
    "parent:platform",
    "managed-by:terraform",
    "factory:azure-landing-zone"
  ]

  depends_on = [spacelift_space.root_level]
}

# Landing Zone child spaces (corp, online)
resource "spacelift_space" "landing_zone_level" {
  for_each = local.landing_zone_spaces

  name             = each.value.name
  description      = each.value.description
  parent_space_id  = spacelift_space.root_level["landing_zones"].id
  inherit_entities = each.value.inherit_entities

  labels = [
    "environment:${lower(each.key)}",
    "parent:landing-zones",
    "managed-by:terraform",
    "factory:azure-landing-zone"
  ]

  depends_on = [spacelift_space.root_level]
}

# Locals for outputs
locals {
  all_spaces = merge(
    spacelift_space.root_level,
    spacelift_space.platform_level,
    spacelift_space.landing_zone_level
  )

  space_ids = {
    for key, space in local.all_spaces :
    key => space.id
  }
}
