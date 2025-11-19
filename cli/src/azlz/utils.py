"""Utility functions for Azure Landing Zone CLI."""

import yaml
from pathlib import Path
from rich.console import Console
from rich.table import Table

# Rich console for pretty output
console = Console()


def load_config(config_file):
    """Load configuration from YAML file."""
    config_path = Path(config_file)

    if not config_path.exists():
        raise FileNotFoundError(f"Config file not found: {config_file}")

    with open(config_path, 'r') as f:
        return yaml.safe_load(f)


def load_stacks_config(stacks_file):
    """Load stacks configuration from YAML file."""
    stacks_path = Path(stacks_file)

    if not stacks_path.exists():
        raise FileNotFoundError(f"Stacks file not found: {stacks_file}")

    with open(stacks_path, 'r') as f:
        return yaml.safe_load(f)


def save_config(config_file, config):
    """Save configuration to YAML file."""
    config_path = Path(config_file)
    config_path.parent.mkdir(parents=True, exist_ok=True)

    with open(config_path, 'w') as f:
        yaml.dump(config, f, default_flow_style=False)


def create_table(title, columns):
    """Create a Rich table with given columns."""
    table = Table(title=title, show_header=True, header_style="bold magenta")

    for column in columns:
        table.add_column(column)

    return table


def validate_cidr(cidr):
    """Validate CIDR notation."""
    import ipaddress

    try:
        ipaddress.ip_network(cidr)
        return True
    except ValueError:
        return False


def check_cidr_overlap(cidr1, cidr2):
    """Check if two CIDR blocks overlap."""
    import ipaddress

    network1 = ipaddress.ip_network(cidr1)
    network2 = ipaddress.ip_network(cidr2)

    return network1.overlaps(network2)
