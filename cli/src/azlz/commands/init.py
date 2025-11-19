"""Initialize command - create new landing zone configuration."""

import click
from azlz.utils import console, load_stacks_config, save_config
from pathlib import Path


def run_init(ctx, type, name, environment, location, address_space, hub, interactive):
    """Run the init command."""

    console.print(f"[bold green]Initializing {type} stack: {name}[/bold green]")

    # Interactive mode
    if interactive:
        name = click.prompt("Stack name", default=name)
        environment = click.prompt("Environment",
                                  type=click.Choice(['production', 'development', 'staging']),
                                  default=environment)
        location = click.prompt("Azure region", default=location or "eastus")
        address_space = click.prompt("VNet CIDR", default=address_space or "10.1.0.0/16")

        if type == 'spoke':
            hub = click.prompt("Hub stack name", default=hub or "hub-connectivity-prod")

    # Build stack configuration
    stack_config = {
        'name': name,
        'environment': environment,
        'location': location or 'eastus',
        'address_space': [address_space or '10.1.0.0/16'],
        'labels': [environment, type, location or 'eastus']
    }

    if type == 'spoke' and hub:
        stack_config['hub'] = hub

    console.print("\n[bold]Stack Configuration:[/bold]")
    console.print(stack_config)

    # Save to stacks.yaml
    stacks_file = Path('stacks.yaml')

    if stacks_file.exists():
        stacks = load_stacks_config(stacks_file)
    else:
        stacks = {'hubs': [], 'spokes': []}

    # Add to appropriate section
    section = 'hubs' if type == 'hub' else 'spokes'
    stacks[section].append(stack_config)

    save_config(stacks_file, stacks)

    console.print(f"\n[bold green]✓[/bold green] Stack configuration added to stacks.yaml")
    console.print(f"\nNext steps:")
    console.print(f"  1. Review the configuration in stacks.yaml")
    console.print(f"  2. Run: azlz validate")
    console.print(f"  3. Run: azlz generate {name}")
    console.print(f"  4. Run: azlz deploy {name}")
