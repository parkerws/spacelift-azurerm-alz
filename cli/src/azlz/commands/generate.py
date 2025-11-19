"""Generate command - generate Terraform configuration."""

from azlz.utils import console


def run_generate(ctx, stack_name, all_stacks, output):
    """Run the generate command."""

    if all_stacks:
        console.print("[bold]Generating Terraform configuration for all stacks...[/bold]")
    else:
        console.print(f"[bold]Generating Terraform configuration for: {stack_name}[/bold]")

    # This is a placeholder - in production, would use Jinja2 templates
    console.print("[yellow]Note: Full implementation pending. Use stack factory templates manually.[/yellow]")
    console.print("\nGenerate files from templates in stack-factory/hub and stack-factory/spoke")
