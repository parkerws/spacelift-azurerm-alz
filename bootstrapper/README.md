# Azure Landing Zone Factory - Bootstrapper

This bootstrapper sets up the foundational Spacelift infrastructure required for the Azure Landing Zone Factory.

## What It Creates

### 1. Spacelift Space Hierarchy

Creates a hierarchical space structure aligned with Azure Landing Zone architecture:

```
Root
├── Platform
│   ├── Connectivity (hub networking)
│   ├── Identity (identity management)
│   └── Management (monitoring and governance)
└── Landing Zones
    ├── Corp (internal workloads)
    └── Online (internet-facing workloads)
```

### 2. Azure Service Principals

Creates dedicated service principals for each environment with appropriate RBAC:

- `sp-spacelift-platform` - Platform services
- `sp-spacelift-connectivity` - Networking resources
- `sp-spacelift-identity` - Identity management
- `sp-spacelift-management` - Monitoring and governance
- `sp-spacelift-landing-zones` - Application workloads

### 3. Spacelift Contexts

Creates contexts for storing credentials and configuration:

- **Azure Environment Context**: Shared tenant and environment configuration
- **Service Principal Contexts**: Per-environment Azure credentials
- **Module Registry Context**: Module registry configuration

## Prerequisites

1. **Spacelift Account**: Active Spacelift account with API access
2. **Azure Permissions**: Ability to create service principals and role assignments
3. **Terraform**: Version >= 1.8.0

## Required Environment Variables

### Spacelift API Credentials

```bash
export SPACELIFT_API_KEY_ENDPOINT="https://your-account.app.spacelift.io"
export SPACELIFT_API_KEY_ID="your-api-key-id"
export SPACELIFT_API_KEY_SECRET="your-api-key-secret"
```

### Azure Authentication

```bash
export ARM_TENANT_ID="your-tenant-id"
export ARM_SUBSCRIPTION_ID="your-subscription-id"
export ARM_CLIENT_ID="your-client-id"
export ARM_CLIENT_SECRET="your-client-secret"
```

## Usage

### 1. Configure Variables

Create a `terraform.tfvars` file:

```hcl
organization_name      = "contoso"
azure_tenant_id        = "00000000-0000-0000-0000-000000000000"
azure_subscription_id  = "00000000-0000-0000-0000-000000000000"
github_repository      = "contoso/azure-landing-zones"

# Optional: Customize space structure
spacelift_spaces = {
  platform = {
    name        = "Platform"
    description = "Platform services and infrastructure"
    parent_id   = "root"
  }
  connectivity = {
    name        = "Connectivity"
    description = "Hub networking and connectivity resources"
    parent_id   = "platform"
  }
  # ... additional spaces
}
```

### 2. Initialize and Apply

```bash
cd bootstrapper
terraform init
terraform plan
terraform apply
```

### 3. Retrieve Service Principal Credentials

After successful apply, retrieve the service principal credentials:

```bash
# View credentials (they are marked sensitive)
terraform output -json service_principal_credentials

# Or get specific credentials
terraform output -json service_principal_credentials | jq -r '.platform.client_id'
```

### 4. Verify Space Creation

```bash
# View created spaces
terraform output space_ids
terraform output space_hierarchy
```

## Post-Bootstrap Steps

After running the bootstrapper:

1. **Attach Contexts to Stacks**: When creating new stacks, attach the appropriate contexts:
   - All stacks: `azure-environment-<org>` context
   - Platform stacks: `azure-sp-platform` context
   - Connectivity stacks: `azure-sp-connectivity` context
   - etc.

2. **Configure Module Registry**: Set up your module sources to reference the modules in this repository

3. **Create Administrative Stacks**: Use the stack factory to create your first administrative stacks

4. **Apply Policies**: Attach policies from the policy library to appropriate spaces

## Configuration Reference

### Variables

| Variable | Description | Required | Default |
|----------|-------------|----------|---------|
| `organization_name` | Organization name for resource naming | Yes | - |
| `azure_tenant_id` | Azure AD Tenant ID | Yes | - |
| `azure_subscription_id` | Azure Subscription ID | Yes | - |
| `create_service_principals` | Create Azure service principals | No | `true` |
| `service_principal_names` | Map of service principal names | No | See variables.tf |
| `spacelift_spaces` | Space hierarchy configuration | No | See variables.tf |
| `github_repository` | GitHub repository (owner/repo) | No | `null` |
| `vcs_provider` | VCS provider | No | `"github"` |
| `azure_environment` | Azure environment | No | `"public"` |
| `worker_pool_id` | Spacelift worker pool ID | No | `null` |

### Outputs

| Output | Description |
|--------|-------------|
| `space_ids` | Map of space names to IDs |
| `space_hierarchy` | Complete space hierarchy structure |
| `service_principal_app_ids` | Service principal client IDs |
| `context_ids` | Spacelift context IDs |
| `service_principal_credentials` | SP credentials (sensitive) |

## Security Considerations

1. **Service Principal Secrets**: The client secrets are stored in Terraform state. Ensure your state is encrypted and access-controlled.

2. **Least Privilege**: By default, service principals get Contributor at subscription level. In production, scope these more tightly:
   ```hcl
   # Example: Scope to specific resource groups
   scope = azurerm_resource_group.connectivity.id
   ```

3. **Secret Rotation**: Client secrets expire after 1 year. Implement a rotation process.

4. **Context Access**: Spacelift contexts inherit down the space hierarchy. Review which stacks have access to which credentials.

## Customization

### Adding Custom Spaces

Add to the `spacelift_spaces` variable:

```hcl
spacelift_spaces = {
  # ... existing spaces
  sandbox = {
    name        = "Sandbox"
    description = "Sandbox environment for testing"
    parent_id   = "root"
  }
}
```

### Using Existing Service Principals

If you have existing service principals:

```hcl
create_service_principals = false

# Then create contexts manually or use data sources
```

### Private Worker Pools

If using private workers:

```hcl
worker_pool_id = "my-worker-pool-id"
```

## Troubleshooting

### Service Principal Creation Fails

If service principal creation fails with permission errors:

1. Ensure you have `Application.ReadWrite.All` permission in Azure AD
2. Or set `create_service_principals = false` and create them manually

### Space Already Exists

If running bootstrapper multiple times, you may encounter conflicts. Use Terraform state to manage existing resources:

```bash
terraform import spacelift_space.root_level[\"platform\"] platform-space-id
```

## Next Steps

After bootstrapping:

1. Review the [Policy Library](../policies/README.md)
2. Explore the [Stack Factory](../factory/README.md)
3. Use the [CLI tool](../cli/README.md) to generate your first stack

## License

MIT License - see [LICENSE](../LICENSE) for details.
