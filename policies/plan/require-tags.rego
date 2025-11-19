package spacelift

# Require Tags Policy
# Ensures all Azure resources have required tags

# Required tags that must be present on all resources
required_tags := [
    "Environment",
    "ManagedBy",
    "CostCenter",
    "Owner"
]

# Get all resource changes that are creates or updates
resource_changes[resource] {
    resource := input.terraform.resource_changes[_]
    resource.change.actions[_] == "create"
}

resource_changes[resource] {
    resource := input.terraform.resource_changes[_]
    resource.change.actions[_] == "update"
}

# Check if resource supports tags
supports_tags(resource) {
    resource.type == "azurerm_resource_group"
}

supports_tags(resource) {
    startswith(resource.type, "azurerm_")
    not startswith(resource.type, "azurerm_role_assignment")
    not startswith(resource.type, "azurerm_policy_assignment")
    resource.change.after.tags
}

# Find resources missing required tags
deny[msg] {
    resource := resource_changes[_]
    supports_tags(resource)
    tag := required_tags[_]
    not resource.change.after.tags[tag]
    msg := sprintf("resource '%s' (%s) is missing required tag: %s", [
        resource.address,
        resource.type,
        tag
    ])
}

# Warn if tag value is empty
warn[msg] {
    resource := resource_changes[_]
    supports_tags(resource)
    tag := required_tags[_]
    value := resource.change.after.tags[tag]
    value == ""
    msg := sprintf("resource '%s' (%s) has empty value for tag: %s", [
        resource.address,
        resource.type,
        tag
    ])
}

# Ensure Environment tag has valid value
deny[msg] {
    resource := resource_changes[_]
    supports_tags(resource)
    env := resource.change.after.tags["Environment"]
    valid_environments := ["Development", "Staging", "Production", "Sandbox"]
    not env in valid_environments
    msg := sprintf("resource '%s' has invalid Environment tag '%s' - must be one of: %v", [
        resource.address,
        env,
        valid_environments
    ])
}

# Ensure ManagedBy tag indicates Terraform
warn[msg] {
    resource := resource_changes[_]
    supports_tags(resource)
    managed_by := resource.change.after.tags["ManagedBy"]
    managed_by != "Terraform"
    managed_by != "Spacelift"
    msg := sprintf("resource '%s' has ManagedBy tag '%s' - consider using 'Terraform' or 'Spacelift'", [
        resource.address,
        managed_by
    ])
}

sample { true }
