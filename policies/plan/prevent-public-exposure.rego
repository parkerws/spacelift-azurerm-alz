package spacelift

# Prevent Public Exposure Policy
# Denies creation of resources with public network access enabled
# Enforces private endpoint usage for PaaS services

# Storage accounts should not allow public access
deny[msg] {
    resource := input.terraform.resource_changes[_]
    resource.type == "azurerm_storage_account"
    resource.change.actions[_] == "create"
    resource.change.after.public_network_access_enabled == true
    msg := sprintf("storage account '%s' must not have public network access enabled", [resource.address])
}

# Storage account blobs should not be public
deny[msg] {
    resource := input.terraform.resource_changes[_]
    resource.type == "azurerm_storage_account"
    resource.change.actions[_] == "create"
    resource.change.after.allow_nested_items_to_be_public == true
    msg := sprintf("storage account '%s' must not allow nested items to be public", [resource.address])
}

# Key vaults should not allow public access in production
deny[msg] {
    resource := input.terraform.resource_changes[_]
    resource.type == "azurerm_key_vault"
    resource.change.actions[_] == "create"
    resource.change.after.public_network_access_enabled == true
    tags := resource.change.after.tags
    tags["Environment"] == "Production"
    msg := sprintf("key vault '%s' in Production must not have public network access enabled", [resource.address])
}

# Container registries should not allow public access in production
deny[msg] {
    resource := input.terraform.resource_changes[_]
    resource.type == "azurerm_container_registry"
    resource.change.actions[_] == "create"
    resource.change.after.public_network_access_enabled == true
    tags := resource.change.after.tags
    tags["Environment"] == "Production"
    msg := sprintf("container registry '%s' in Production must not have public network access enabled", [resource.address])
}

# SQL databases should not allow public access
deny[msg] {
    resource := input.terraform.resource_changes[_]
    resource.type == "azurerm_mssql_server"
    resource.change.actions[_] == "create"
    resource.change.after.public_network_access_enabled == true
    msg := sprintf("SQL server '%s' must not have public network access enabled", [resource.address])
}

# Warn if NSG allows SSH from internet
warn[msg] {
    resource := input.terraform.resource_changes[_]
    resource.type == "azurerm_network_security_rule"
    resource.change.actions[_] == "create"
    resource.change.after.access == "Allow"
    resource.change.after.direction == "Inbound"
    resource.change.after.destination_port_range == "22"
    source := resource.change.after.source_address_prefix
    contains(source, "*")
    msg := sprintf("NSG rule '%s' allows SSH from internet - consider restricting source", [resource.address])
}

# Warn if NSG allows RDP from internet
warn[msg] {
    resource := input.terraform.resource_changes[_]
    resource.type == "azurerm_network_security_rule"
    resource.change.actions[_] == "create"
    resource.change.after.access == "Allow"
    resource.change.after.direction == "Inbound"
    resource.change.after.destination_port_range == "3389"
    source := resource.change.after.source_address_prefix
    contains(source, "*")
    msg := sprintf("NSG rule '%s' allows RDP from internet - consider restricting source", [resource.address])
}

sample { true }
