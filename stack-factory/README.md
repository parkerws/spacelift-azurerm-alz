# Hub-and-Spoke Stack Factory

Dynamic Spacelift stack creation for Azure hub-and-spoke landing zones.

## Overview

The stack factory uses the Spacelift Terraform provider to dynamically create and manage stacks based on configuration files. This enables infrastructure-as-code for Spacelift itself.

## Architecture

```
Stack Factory (Administrative Stack)
├── Hub Stacks
│   ├── hub-connectivity-prod
│   └── hub-connectivity-dev
└── Spoke Stacks
    ├── spoke-corp-prod-001
    ├── spoke-corp-prod-002
    ├── spoke-online-prod-001
    └── spoke-online-dev-001
```

### Stack Dependencies

```
hub-connectivity-prod
├── spoke-corp-prod-001 (depends on hub)
├── spoke-corp-prod-002 (depends on hub)
└── spoke-online-prod-001 (depends on hub)
```

## Components

### Admin Stack (`admin/`)

The administrative stack that creates all other stacks:
- Uses Spacelift Terraform provider
- Reads configuration from `stacks.yaml`
- Creates hub and spoke stacks dynamically
- Manages stack dependencies
- Attaches contexts and policies

### Hub Templates (`hub/`)

Template for hub (connectivity) stacks:
- Azure Firewall
- VPN Gateway
- Azure Bastion
- DDoS Protection Plan
- Hub VNet with subnets

### Spoke Templates (`spoke/`)

Template for spoke (landing zone) stacks:
- Spoke VNet
- Subnets with NSGs
- Route tables (UDR to hub)
- VNet peering to hub
- Optional: Private endpoints, service endpoints

## Configuration

### Stack Configuration File

Create `stacks.yaml`:

```yaml
hubs:
  - name: hub-connectivity-prod
    space: networking/hub
    environment: production
    location: eastus
    address_space: ["10.0.0.0/16"]
    subnets:
      - name: AzureFirewallSubnet
        address_prefix: "10.0.0.0/26"
      - name: GatewaySubnet
        address_prefix: "10.0.1.0/27"
      - name: AzureBastionSubnet
        address_prefix: "10.0.2.0/27"
    firewall:
      sku_name: AZFW_VNet
      sku_tier: Standard
      public_ip_count: 2
    vpn_gateway:
      type: VpnGw2
      enable_bgp: true
    bastion:
      sku: Standard
    labels:
      - production
      - hub
      - eastus

  - name: hub-connectivity-dev
    space: networking/hub
    environment: development
    location: eastus2
    address_space: ["10.100.0.0/16"]
    # ... similar configuration ...

spokes:
  - name: spoke-corp-prod-001
    space: landing-zones/corp
    environment: production
    location: eastus
    hub: hub-connectivity-prod  # Dependency
    address_space: ["10.1.0.0/16"]
    subnets:
      - name: snet-workload
        address_prefix: "10.1.0.0/24"
        service_endpoints:
          - Microsoft.KeyVault
          - Microsoft.Storage
      - name: snet-data
        address_prefix: "10.1.1.0/24"
    route_to_hub: true
    private_endpoints: true
    labels:
      - production
      - corp
      - eastus

  - name: spoke-online-prod-001
    space: landing-zones/online
    environment: production
    location: eastus
    hub: hub-connectivity-prod
    address_space: ["10.2.0.0/16"]
    # ... similar configuration ...
```

### Stack Factory Variables

```hcl
# stacks.yaml location
stacks_config_file = "./stacks.yaml"

# Space references from bootstrapper
space_ids = {
  landing_zones_corp   = "space-123"
  landing_zones_online = "space-456"
  networking_hub       = "space-789"
}

# Context references from bootstrapper
context_ids = {
  azure_prod = "context-abc"
  azure_dev  = "context-def"
}

# Policy references
policy_ids = {
  production_approval = "policy-111"
  cost_control       = "policy-222"
  compliance         = "policy-333"
}

# Git repository
repository = "infrastructure-stacks"
repository_namespace = "your-org"
```

## Usage

### 1. Deploy Admin Stack

First, deploy the administrative stack to Spacelift:

```bash
cd admin
terraform init
terraform plan
terraform apply
```

### 2. Configure Stacks

Edit `stacks.yaml` to define your hub and spoke stacks.

### 3. Trigger Run

The admin stack will:
1. Parse `stacks.yaml`
2. Create hub stacks
3. Create spoke stacks with hub dependencies
4. Attach appropriate contexts and policies
5. Set up VCS integration

### 4. Deploy Hub

In Spacelift UI:
1. Navigate to hub stack
2. Trigger run
3. Review and confirm

### 5. Deploy Spokes

After hub is deployed:
1. Spoke stacks will auto-trigger (dependency)
2. Review and confirm each spoke

## Features

### Automatic Dependency Management

Spokes automatically depend on their hub:

```hcl
resource "spacelift_stack" "spoke" {
  for_each = local.spokes

  name = each.value.name
  # ...

  dynamic "depends_on" {
    for_each = each.value.hub != null ? [each.value.hub] : []
    content {
      stack_id = spacelift_stack.hub[depends_on.value].id
    }
  }
}
```

### Naming Convention Enforcement

Stack names follow pattern:
- Hub: `hub-{purpose}-{environment}`
- Spoke: `spoke-{zone}-{environment}-{number}`

### Policy Attachment

Policies auto-attach based on:
- Environment label (production → approval policy)
- Space membership (landing zones → compliance)
- Resource type (hub → network policies)

### Context Attachment

Contexts auto-attach based on:
- Environment (production → prod credentials)
- Common variables attached to all stacks

## Stack Lifecycle

### Adding a New Spoke

1. Add spoke definition to `stacks.yaml`
2. Commit and push changes
3. Admin stack will detect and create new spoke stack
4. New spoke stack will auto-deploy after hub

### Modifying a Stack

1. Update stack configuration in `stacks.yaml`
2. Commit and push changes
3. Admin stack will update stack definition
4. No impact on deployed infrastructure (only stack metadata)

### Deleting a Stack

1. Remove from `stacks.yaml`
2. Commit and push changes
3. Admin stack will destroy stack resources
4. Manually delete stack from Spacelift if needed

## Advanced Features

### Multi-Region Hubs

Deploy hub in each region:

```yaml
hubs:
  - name: hub-connectivity-prod-eastus
    location: eastus
    # ...
  - name: hub-connectivity-prod-westus
    location: westus
    # ...
```

### Hub-to-Hub Peering

For global routing:

```yaml
hub_peering:
  - source: hub-connectivity-prod-eastus
    destination: hub-connectivity-prod-westus
    allow_forwarded_traffic: true
    allow_gateway_transit: true
```

### Custom Module Versions

Pin module versions per stack:

```yaml
spokes:
  - name: spoke-corp-prod-001
    module_versions:
      azure-vnet: "v1.2.3"
      azure-subnet: "v1.1.0"
```

## Troubleshooting

### Stack Creation Fails

Check:
1. Space IDs are correct
2. Context IDs exist
3. Spacelift API token has permissions
4. Git repository is accessible

### Dependency Issues

If spoke deploys before hub:
1. Verify hub name in spoke config matches hub stack name
2. Check dependency configuration in admin stack
3. Review stack creation order

### VCS Integration Issues

If Git integration fails:
1. Verify repository exists and is accessible
2. Check GitHub/GitLab integration is configured in Spacelift
3. Verify branch names are correct

## Best Practices

1. **Version Control**: Keep `stacks.yaml` in Git
2. **Review Changes**: Use PR process for stack configuration changes
3. **Testing**: Create dev/test stacks before production
4. **Documentation**: Document custom configurations in stack descriptions
5. **Monitoring**: Set up notifications for stack failures

## References

- [Spacelift Stack Documentation](https://docs.spacelift.io/concepts/stack)
- [Stack Dependencies](https://docs.spacelift.io/concepts/stack/stack-dependencies)
- [Spacelift Terraform Provider](https://registry.terraform.io/providers/spacelift-io/spacelift/latest/docs)
