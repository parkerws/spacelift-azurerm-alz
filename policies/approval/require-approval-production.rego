package spacelift

# Require Approval for Production Policy
# Enforces manual approval for production environment changes

# Check if this is a tracked run (not a proposed run)
tracked { input.run.type == "TRACKED" }

# Check if any resource changes affect production
affects_production {
    resource := input.terraform.resource_changes[_]
    tags := resource.change.after.tags
    tags["Environment"] == "Production"
    resource.change.actions[_] != "no-op"
}

# Check if this is a delete operation
has_deletions {
    resource := input.terraform.resource_changes[_]
    resource.change.actions[_] == "delete"
}

# Check if this is a replace operation
has_replacements {
    resource := input.terraform.resource_changes[_]
    count(resource.change.actions) == 2
    resource.change.actions[_] == "delete"
    resource.change.actions[_] == "create"
}

# Check space to determine environment
in_production_space {
    input.run.based_on_local_workspace == false
    contains(lower(input.run.labels[_]), "production")
}

in_production_space {
    input.run.based_on_local_workspace == false
    contains(lower(input.run.labels[_]), "prod")
}

# Require approval if affecting production
approve[msg] {
    tracked
    affects_production
    msg := "Production environment changes require approval"
}

# Require approval for production space regardless of tags
approve[msg] {
    tracked
    in_production_space
    msg := "Changes in production space require approval"
}

# Always require approval for deletions in any environment
approve[msg] {
    tracked
    has_deletions
    msg := "Deletion operations require approval"
}

# Always require approval for replacements
approve[msg] {
    tracked
    has_replacements
    msg := "Resource replacement operations require approval"
}

# Require approval if cost estimate is high
approve[msg] {
    tracked
    monthly_cost := to_number(input.third_party_metadata.custom.cost_estimation.monthly_cost)
    monthly_cost > 2000
    msg := sprintf("High cost estimate ($%.2f/month) requires approval", [monthly_cost])
}

sample { true }
