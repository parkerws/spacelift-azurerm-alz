output "hub_stack_ids" {
  description = "Map of hub stack names to their IDs"
  value = {
    for k, v in spacelift_stack.hub :
    k => v.id
  }
}

output "spoke_stack_ids" {
  description = "Map of spoke stack names to their IDs"
  value = {
    for k, v in spacelift_stack.spoke :
    k => v.id
  }
}

output "all_stacks" {
  description = "Complete list of all created stacks"
  value = merge(
    {
      for k, v in spacelift_stack.hub :
      k => {
        id          = v.id
        name        = v.name
        type        = "hub"
        space_id    = v.space_id
        description = v.description
      }
    },
    {
      for k, v in spacelift_stack.spoke :
      k => {
        id          = v.id
        name        = v.name
        type        = "spoke"
        space_id    = v.space_id
        description = v.description
      }
    }
  )
}

output "stack_dependencies" {
  description = "Map of spoke to hub dependencies"
  value = {
    for k, v in spacelift_stack_dependency.spoke_to_hub :
    k => {
      spoke_id = v.stack_id
      hub_id   = v.depends_on_stack_id
    }
  }
}
