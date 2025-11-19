resource "azurerm_management_group_policy_assignment" "mg" {
  count = can(regex("^/providers/[Mm]icrosoft\\.[Mm]anagement/managementGroups/", var.scope)) ? 1 : 0

  name                 = var.name
  display_name         = coalesce(var.display_name, var.name)
  description          = var.description
  policy_definition_id = var.policy_definition_id
  management_group_id  = var.scope
  not_scopes           = var.not_scopes
  enforce              = var.enforcement_mode == "Default"
  parameters           = var.parameters
  metadata             = var.metadata
  location             = var.location

  dynamic "identity" {
    for_each = var.identity != null ? [var.identity] : []
    content {
      type         = identity.value.type
      identity_ids = identity.value.type == "UserAssigned" ? identity.value.identity_ids : null
    }
  }

  dynamic "non_compliance_message" {
    for_each = var.non_compliance_messages
    content {
      content                        = non_compliance_message.value.content
      policy_definition_reference_id = non_compliance_message.value.policy_definition_reference_id
    }
  }

  dynamic "resource_selectors" {
    for_each = var.resource_selectors
    content {
      name = resource_selectors.value.name
      dynamic "selectors" {
        for_each = resource_selectors.value.selectors
        content {
          kind   = selectors.value.kind
          in     = selectors.value.in
          not_in = selectors.value.not_in
        }
      }
    }
  }

  dynamic "overrides" {
    for_each = var.overrides
    content {
      value = overrides.value.value
      dynamic "selectors" {
        for_each = overrides.value.selectors
        content {
          kind   = selectors.value.kind
          in     = selectors.value.in
          not_in = selectors.value.not_in
        }
      }
    }
  }
}

resource "azurerm_subscription_policy_assignment" "sub" {
  count = can(regex("^/subscriptions/[^/]+$", var.scope)) ? 1 : 0

  name                 = var.name
  display_name         = coalesce(var.display_name, var.name)
  description          = var.description
  policy_definition_id = var.policy_definition_id
  subscription_id      = var.scope
  not_scopes           = var.not_scopes
  enforce              = var.enforcement_mode == "Default"
  parameters           = var.parameters
  metadata             = var.metadata
  location             = var.location

  dynamic "identity" {
    for_each = var.identity != null ? [var.identity] : []
    content {
      type         = identity.value.type
      identity_ids = identity.value.type == "UserAssigned" ? identity.value.identity_ids : null
    }
  }

  dynamic "non_compliance_message" {
    for_each = var.non_compliance_messages
    content {
      content                        = non_compliance_message.value.content
      policy_definition_reference_id = non_compliance_message.value.policy_definition_reference_id
    }
  }

  dynamic "resource_selectors" {
    for_each = var.resource_selectors
    content {
      name = resource_selectors.value.name
      dynamic "selectors" {
        for_each = resource_selectors.value.selectors
        content {
          kind   = selectors.value.kind
          in     = selectors.value.in
          not_in = selectors.value.not_in
        }
      }
    }
  }

  dynamic "overrides" {
    for_each = var.overrides
    content {
      value = overrides.value.value
      dynamic "selectors" {
        for_each = overrides.value.selectors
        content {
          kind   = selectors.value.kind
          in     = selectors.value.in
          not_in = selectors.value.not_in
        }
      }
    }
  }
}

resource "azurerm_resource_group_policy_assignment" "rg" {
  count = can(regex("^/subscriptions/[^/]+/resourceGroups/", var.scope)) ? 1 : 0

  name                 = var.name
  display_name         = coalesce(var.display_name, var.name)
  description          = var.description
  policy_definition_id = var.policy_definition_id
  resource_group_id    = var.scope
  not_scopes           = var.not_scopes
  enforce              = var.enforcement_mode == "Default"
  parameters           = var.parameters
  metadata             = var.metadata
  location             = var.location

  dynamic "identity" {
    for_each = var.identity != null ? [var.identity] : []
    content {
      type         = identity.value.type
      identity_ids = identity.value.type == "UserAssigned" ? identity.value.identity_ids : null
    }
  }

  dynamic "non_compliance_message" {
    for_each = var.non_compliance_messages
    content {
      content                        = non_compliance_message.value.content
      policy_definition_reference_id = non_compliance_message.value.policy_definition_reference_id
    }
  }

  dynamic "resource_selectors" {
    for_each = var.resource_selectors
    content {
      name = resource_selectors.value.name
      dynamic "selectors" {
        for_each = resource_selectors.value.selectors
        content {
          kind   = selectors.value.kind
          in     = selectors.value.in
          not_in = selectors.value.not_in
        }
      }
    }
  }

  dynamic "overrides" {
    for_each = var.overrides
    content {
      value = overrides.value.value
      dynamic "selectors" {
        for_each = overrides.value.selectors
        content {
          kind   = selectors.value.kind
          in     = selectors.value.in
          not_in = selectors.value.not_in
        }
      }
    }
  }
}

# Locals to simplify output
locals {
  assignment = coalesce(
    try(azurerm_management_group_policy_assignment.mg[0], null),
    try(azurerm_subscription_policy_assignment.sub[0], null),
    try(azurerm_resource_group_policy_assignment.rg[0], null)
  )
}
