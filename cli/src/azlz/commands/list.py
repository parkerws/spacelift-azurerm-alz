"""List command - list configured stacks."""

import json
from azlz.utils import console, load_stacks_config, create_table


def run_list(ctx, type, hub, format):
    """Run the list command."""

    try:
        stacks = load_stacks_config('stacks.yaml')
    except FileNotFoundError:
        console.print("[red]Error: stacks.yaml not found[/red]")
        return

    # Filter stacks
    hubs = stacks.get('hubs', []) if type in ['hub', 'all'] else []
    spokes = stacks.get('spokes', []) if type in ['spoke', 'all'] else []

    # Filter spokes by hub
    if hub:
        spokes = [s for s in spokes if s.get('hub') == hub]

    # Output as JSON
    if format == 'json':
        output = {
            'hubs': hubs,
            'spokes': spokes
        }
        console.print(json.dumps(output, indent=2))
        return

    # Output as table
    if hubs:
        table = create_table("Hub Stacks", ["Name", "Environment", "Location", "Address Space"])
        for hub in hubs:
            table.add_row(
                hub.get('name', ''),
                hub.get('environment', ''),
                hub.get('location', ''),
                ', '.join(hub.get('address_space', []))
            )
        console.print(table)

    if spokes:
        table = create_table("Spoke Stacks",
                           ["Name", "Environment", "Location", "Hub", "Address Space"])
        for spoke in spokes:
            table.add_row(
                spoke.get('name', ''),
                spoke.get('environment', ''),
                spoke.get('location', ''),
                spoke.get('hub', ''),
                ', '.join(spoke.get('address_space', []))
            )
        console.print(table)

    if not hubs and not spokes:
        console.print("[yellow]No stacks found[/yellow]")
