package spacelift

# Hub-Spoke Dependencies Policy
# Ensures hub infrastructure is deployed before spoke networks
# Triggers dependent stacks when hub changes

# Identify hub stacks by labels or name
is_hub_stack {
    contains(lower(input.stack.name), "hub")
}

is_hub_stack {
    contains(lower(input.stack.labels[_]), "hub")
}

is_hub_stack {
    contains(lower(input.stack.labels[_]), "connectivity")
}

# Identify spoke stacks
is_spoke_stack {
    contains(lower(input.stack.name), "spoke")
}

is_spoke_stack {
    contains(lower(input.stack.labels[_]), "spoke")
}

# Identify platform stacks (management, logging, etc.)
is_platform_stack {
    contains(lower(input.stack.labels[_]), "platform")
}

is_platform_stack {
    contains(lower(input.stack.labels[_]), "management")
}

is_platform_stack {
    contains(lower(input.stack.labels[_]), "shared-services")
}

# Trigger hub stack changes first
track {
    is_hub_stack
}

# Trigger platform stacks when hub completes
trigger[stack_name] {
    is_hub_stack
    input.run.state == "FINISHED"
    input.run.type == "TRACKED"
    # Get all platform stacks (would come from input in real scenario)
    stack_name := input.run.labels[_]
    contains(stack_name, "platform")
}

# Trigger spoke stacks when hub completes
trigger[stack_name] {
    is_hub_stack
    input.run.state == "FINISHED"
    input.run.type == "TRACKED"
    # Get all spoke stacks (would come from input in real scenario)
    stack_name := input.run.labels[_]
    contains(stack_name, "spoke")
}

# Don't allow spoke deployment if hub isn't healthy
# This would require querying other stack states in production
deny[msg] {
    is_spoke_stack
    # In production, check if hub stack is in healthy state
    # For now, this is a placeholder
    not is_hub_deployed
    msg := "Cannot deploy spoke network - hub infrastructure must be deployed first"
}

# Helper: Check if hub is deployed (placeholder)
is_hub_deployed {
    # In production, this would check the state of the hub stack
    # For example, using Spacelift API or terraform_remote_state
    true
}

sample { true }
