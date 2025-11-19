"""Config command - manage CLI configuration."""

from azlz.utils import console, load_config, save_config
from pathlib import Path


def show_config(ctx):
    """Show current configuration."""
    config = ctx.obj.get('CONFIG', {})

    console.print("[bold]Current Configuration:[/bold]")
    console.print(config)


def set_config(ctx, key, value):
    """Set configuration value."""
    config_file = ctx.obj['CONFIG_FILE']

    try:
        config = load_config(config_file)
    except FileNotFoundError:
        config = {}

    # Parse nested keys (e.g., "spacelift.endpoint")
    keys = key.split('.')
    current = config
    for k in keys[:-1]:
        if k not in current:
            current[k] = {}
        current = current[k]

    current[keys[-1]] = value

    save_config(config_file, config)

    console.print(f"[green]✓[/green] Set {key} = {value}")


def init_config(ctx):
    """Initialize configuration."""
    config_file = ctx.obj['CONFIG_FILE']

    console.print("[bold]Initializing configuration...[/bold]")

    # Default configuration
    config = {
        'spacelift': {
            'endpoint': 'https://your-account.app.spacelift.io',
            'api_key_id': '${SPACELIFT_API_KEY_ID}',
            'api_key_secret': '${SPACELIFT_API_KEY_SECRET}'
        },
        'azure': {
            'tenant_id': '${AZURE_TENANT_ID}',
            'subscription_id': '${AZURE_SUBSCRIPTION_ID}'
        },
        'defaults': {
            'environment': 'development',
            'location': 'eastus',
            'terraform_version': '1.8.0'
        }
    }

    save_config(config_file, config)

    console.print(f"[green]✓[/green] Configuration initialized at {config_file}")
    console.print("\nEdit the configuration file to set your values.")
