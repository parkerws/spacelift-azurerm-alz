resource "azurerm_container_registry" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku

  admin_enabled                 = var.admin_enabled
  public_network_access_enabled = var.public_network_access_enabled
  quarantine_policy_enabled     = var.sku == "Premium" ? var.quarantine_policy_enabled : null
  zone_redundancy_enabled       = var.sku == "Premium" ? var.zone_redundancy_enabled : false
  export_policy_enabled         = var.sku == "Premium" ? var.export_policy_enabled : true
  anonymous_pull_enabled        = var.sku != "Basic" ? var.anonymous_pull_enabled : null
  data_endpoint_enabled         = var.sku == "Premium" ? var.data_endpoint_enabled : null
  network_rule_bypass_option    = var.sku == "Premium" ? var.network_rule_bypass_option : null

  dynamic "network_rule_set" {
    for_each = var.sku == "Premium" && var.network_rule_set != null ? [var.network_rule_set] : []
    content {
      default_action = network_rule_set.value.default_action

      dynamic "ip_rule" {
        for_each = network_rule_set.value.ip_rule
        content {
          action   = ip_rule.value.action
          ip_range = ip_rule.value.ip_range
        }
      }

      dynamic "virtual_network" {
        for_each = network_rule_set.value.virtual_network
        content {
          action    = virtual_network.value.action
          subnet_id = virtual_network.value.subnet_id
        }
      }
    }
  }

  dynamic "retention_policy" {
    for_each = var.sku == "Premium" && var.retention_policy != null ? [var.retention_policy] : []
    content {
      days    = retention_policy.value.days
      enabled = retention_policy.value.enabled
    }
  }

  dynamic "trust_policy" {
    for_each = var.sku == "Premium" && var.trust_policy != null ? [var.trust_policy] : []
    content {
      enabled = trust_policy.value.enabled
    }
  }

  dynamic "identity" {
    for_each = var.identity != null ? [var.identity] : []
    content {
      type         = identity.value.type
      identity_ids = identity.value.type != "SystemAssigned" ? identity.value.identity_ids : null
    }
  }

  dynamic "encryption" {
    for_each = var.sku == "Premium" && var.encryption != null ? [var.encryption] : []
    content {
      enabled            = encryption.value.enabled
      key_vault_key_id   = encryption.value.key_vault_key_id
      identity_client_id = encryption.value.identity_client_id
    }
  }

  dynamic "georeplications" {
    for_each = var.sku == "Premium" ? var.georeplications : []
    content {
      location                  = georeplications.value.location
      regional_endpoint_enabled = georeplications.value.regional_endpoint_enabled
      zone_redundancy_enabled   = georeplications.value.zone_redundancy_enabled
      tags                      = georeplications.value.tags
    }
  }

  tags = var.tags
}

resource "azurerm_container_registry_webhook" "this" {
  for_each = var.webhooks

  name                = each.key
  resource_group_name = var.resource_group_name
  location            = var.location
  registry_name       = azurerm_container_registry.this.name

  service_uri    = each.value.service_uri
  actions        = each.value.actions
  status         = each.value.status
  scope          = each.value.scope
  custom_headers = each.value.custom_headers
}
