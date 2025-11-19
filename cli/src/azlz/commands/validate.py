"""Validate command - validate stack configuration."""

from azlz.utils import console, load_stacks_config, validate_cidr, check_cidr_overlap


def run_validate(ctx, config_file, stack, verbose, check_cidrs, check_dependencies):
    """Run the validate command."""

    console.print(f"[bold]Validating configuration: {config_file}[/bold]")

    try:
        stacks = load_stacks_config(config_file)
    except FileNotFoundError:
        console.print(f"[red]Error: File not found: {config_file}[/red]")
        return False
    except Exception as e:
        console.print(f"[red]Error parsing YAML: {e}[/red]")
        return False

    errors = []
    warnings = []

    # Validate hubs
    if 'hubs' in stacks:
        for hub in stacks['hubs']:
            if stack and hub.get('name') != stack:
                continue

            # Check required fields
            if not hub.get('name'):
                errors.append("Hub missing 'name' field")
            if not hub.get('address_space'):
                errors.append(f"Hub '{hub.get('name')}' missing 'address_space'")

            # Validate CIDR
            if hub.get('address_space'):
                for cidr in hub['address_space']:
                    if not validate_cidr(cidr):
                        errors.append(f"Invalid CIDR in hub '{hub.get('name')}': {cidr}")

    # Validate spokes
    if 'spokes' in stacks:
        for spoke in stacks['spokes']:
            if stack and spoke.get('name') != stack:
                continue

            # Check required fields
            if not spoke.get('name'):
                errors.append("Spoke missing 'name' field")
            if not spoke.get('address_space'):
                errors.append(f"Spoke '{spoke.get('name')}' missing 'address_space'")
            if not spoke.get('hub'):
                warnings.append(f"Spoke '{spoke.get('name')}' missing 'hub' dependency")

            # Validate CIDR
            if spoke.get('address_space'):
                for cidr in spoke['address_space']:
                    if not validate_cidr(cidr):
                        errors.append(f"Invalid CIDR in spoke '{spoke.get('name')}': {cidr}")

            # Check hub dependency exists
            if check_dependencies and spoke.get('hub'):
                hub_exists = any(h.get('name') == spoke['hub'] for h in stacks.get('hubs', []))
                if not hub_exists:
                    errors.append(f"Spoke '{spoke.get('name')}' references non-existent hub: {spoke['hub']}")

    # Check for CIDR overlaps
    if check_cidrs:
        all_cidrs = []
        for hub in stacks.get('hubs', []):
            for cidr in hub.get('address_space', []):
                all_cidrs.append((hub['name'], cidr))
        for spoke in stacks.get('spokes', []):
            for cidr in spoke.get('address_space', []):
                all_cidrs.append((spoke['name'], cidr))

        for i, (name1, cidr1) in enumerate(all_cidrs):
            for name2, cidr2 in all_cidrs[i+1:]:
                if check_cidr_overlap(cidr1, cidr2):
                    errors.append(f"CIDR overlap detected: {name1} ({cidr1}) and {name2} ({cidr2})")

    # Print results
    if errors:
        console.print(f"\n[bold red]✗ Validation failed with {len(errors)} error(s):[/bold red]")
        for error in errors:
            console.print(f"  [red]✗[/red] {error}")

    if warnings:
        console.print(f"\n[yellow]⚠ {len(warnings)} warning(s):[/yellow]")
        for warning in warnings:
            console.print(f"  [yellow]⚠[/yellow] {warning}")

    if not errors and not warnings:
        console.print("\n[bold green]✓ Validation successful![/bold green]")

    return len(errors) == 0
