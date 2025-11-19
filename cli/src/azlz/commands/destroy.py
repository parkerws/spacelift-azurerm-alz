"""Destroy command - remove stack from Spacelift."""

from azlz.utils import console


def run_destroy(ctx, stack_name, force):
    """Run the destroy command."""

    console.print(f"[bold red]Destroying stack: {stack_name}[/bold red]")

    if force:
        console.print("[yellow]Warning: Force mode - skipping dependency checks[/yellow]")

    # This is a placeholder - in production, would use Spacelift API
    console.print("[yellow]Note: Full implementation pending. Use Spacelift UI or Terraform.[/yellow]")
    console.print("\nRemove stack from stack-factory/admin configuration and apply.")
