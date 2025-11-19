"""Deploy command - deploy stack to Spacelift."""

from azlz.utils import console


def run_deploy(ctx, stack_name, all_stacks, auto_approve, dry_run):
    """Run the deploy command."""

    mode = "Plan" if dry_run else "Deploy"

    if all_stacks:
        console.print(f"[bold]{mode}ing all stacks...[/bold]")
    else:
        console.print(f"[bold]{mode}ing stack: {stack_name}[/bold]")

    # This is a placeholder - in production, would use Spacelift API
    console.print("[yellow]Note: Full implementation pending. Use Spacelift UI or Terraform.[/yellow]")
    console.print("\nUse the stack factory admin stack to deploy via Spacelift.")
