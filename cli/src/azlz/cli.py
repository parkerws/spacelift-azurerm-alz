#!/usr/bin/env python3
"""
Azure Landing Zone Factory CLI

Main command-line interface for managing Azure Landing Zone stacks with Spacelift.
"""

import click
import sys
from pathlib import Path

from azlz.commands import init, validate, generate, deploy, list_stacks, destroy, config
from azlz.utils import console, load_config


@click.group()
@click.option('--debug', is_flag=True, help='Enable debug logging')
@click.option('--config-file', type=click.Path(), help='Path to config file')
@click.pass_context
def main(ctx, debug, config_file):
    """Azure Landing Zone Factory CLI for Spacelift.

    Manage hub-and-spoke landing zones with Infrastructure-as-Code.
    """
    ctx.ensure_object(dict)
    ctx.obj['DEBUG'] = debug
    ctx.obj['CONFIG_FILE'] = config_file or Path.home() / '.azlz' / 'config.yaml'

    # Load configuration
    try:
        ctx.obj['CONFIG'] = load_config(ctx.obj['CONFIG_FILE'])
    except FileNotFoundError:
        if debug:
            console.print("[yellow]Warning: Config file not found. Using defaults.[/yellow]")
        ctx.obj['CONFIG'] = {}
    except Exception as e:
        if debug:
            console.print(f"[red]Error loading config: {e}[/red]")
        ctx.obj['CONFIG'] = {}


@main.command()
@click.argument('type', type=click.Choice(['hub', 'spoke']))
@click.option('--name', required=True, help='Stack name')
@click.option('--environment', type=click.Choice(['production', 'development', 'staging']),
              default='development', help='Environment')
@click.option('--location', help='Azure region')
@click.option('--address-space', help='VNet CIDR (e.g., 10.1.0.0/16)')
@click.option('--hub', help='Hub stack name (for spokes)')
@click.option('--interactive', is_flag=True, help='Interactive mode')
@click.pass_context
def init(ctx, type, name, environment, location, address_space, hub, interactive):
    """Initialize a new landing zone stack configuration."""
    from azlz.commands.init import run_init

    run_init(ctx, type, name, environment, location, address_space, hub, interactive)


@main.command()
@click.argument('config_file', type=click.Path(exists=True), default='stacks.yaml')
@click.option('--stack', help='Validate specific stack')
@click.option('--verbose', is_flag=True, help='Verbose output')
@click.option('--check-cidrs', is_flag=True, help='Check for CIDR overlaps')
@click.option('--check-dependencies', is_flag=True, help='Verify dependencies')
@click.pass_context
def validate(ctx, config_file, stack, verbose, check_cidrs, check_dependencies):
    """Validate stack configuration."""
    from azlz.commands.validate import run_validate

    run_validate(ctx, config_file, stack, verbose, check_cidrs, check_dependencies)


@main.command()
@click.argument('stack_name', required=False)
@click.option('--all', 'all_stacks', is_flag=True, help='Generate all stacks')
@click.option('--output', type=click.Path(), help='Output directory')
@click.pass_context
def generate(ctx, stack_name, all_stacks, output):
    """Generate Terraform configuration from templates."""
    from azlz.commands.generate import run_generate

    if not stack_name and not all_stacks:
        console.print("[red]Error: Specify --stack or --all[/red]")
        sys.exit(1)

    run_generate(ctx, stack_name, all_stacks, output)


@main.command()
@click.argument('stack_name', required=False)
@click.option('--all', 'all_stacks', is_flag=True, help='Deploy all stacks')
@click.option('--auto-approve', is_flag=True, help='Auto-approve deployment')
@click.option('--dry-run', is_flag=True, help='Plan only (no apply)')
@click.pass_context
def deploy(ctx, stack_name, all_stacks, auto_approve, dry_run):
    """Deploy stack to Spacelift."""
    from azlz.commands.deploy import run_deploy

    if not stack_name and not all_stacks:
        console.print("[red]Error: Specify stack name or --all[/red]")
        sys.exit(1)

    run_deploy(ctx, stack_name, all_stacks, auto_approve, dry_run)


@main.command('list')
@click.option('--type', type=click.Choice(['hub', 'spoke', 'all']), default='all',
              help='Filter by type')
@click.option('--hub', help='Filter spokes by hub')
@click.option('--format', type=click.Choice(['table', 'json']), default='table',
              help='Output format')
@click.pass_context
def list_command(ctx, type, hub, format):
    """List configured stacks."""
    from azlz.commands.list import run_list

    run_list(ctx, type, hub, format)


@main.command()
@click.argument('stack_name')
@click.option('--confirm', is_flag=True, help='Confirm destruction')
@click.option('--force', is_flag=True, help='Force destroy (skip dependencies)')
@click.pass_context
def destroy(ctx, stack_name, confirm, force):
    """Remove stack from Spacelift."""
    from azlz.commands.destroy import run_destroy

    if not confirm:
        if not click.confirm(f'Are you sure you want to destroy {stack_name}?'):
            console.print("[yellow]Aborted.[/yellow]")
            return

    run_destroy(ctx, stack_name, force)


@main.group()
def config():
    """Manage CLI configuration."""
    pass


@config.command('show')
@click.pass_context
def config_show(ctx):
    """Show current configuration."""
    from azlz.commands.config import show_config

    show_config(ctx)


@config.command('set')
@click.argument('key')
@click.argument('value')
@click.pass_context
def config_set(ctx, key, value):
    """Set configuration value."""
    from azlz.commands.config import set_config

    set_config(ctx, key, value)


@config.command('init')
@click.pass_context
def config_init(ctx):
    """Initialize configuration."""
    from azlz.commands.config import init_config

    init_config(ctx)


if __name__ == '__main__':
    main()
