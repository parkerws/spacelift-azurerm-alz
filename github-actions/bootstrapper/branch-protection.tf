# Branch Protection Rules
# Enforce code review and status checks before merging

resource "github_branch_protection" "main" {
  count = var.enable_branch_protection ? length(var.protected_branches) : 0

  repository_id = data.github_repository.this.node_id
  pattern       = var.protected_branches[count.index]

  # Require pull request reviews
  required_pull_request_reviews {
    dismiss_stale_reviews           = true
    require_code_owner_reviews      = true
    required_approving_review_count = var.required_approvals
    restrict_dismissals             = false
  }

  # Require status checks
  required_status_checks {
    strict   = true
    contexts = [
      "terraform-validate",
      "terraform-fmt",
      "security-scan",
      "cost-estimation"
    ]
  }

  # Enforce restrictions
  enforce_admins                  = false
  require_signed_commits          = true
  require_conversation_resolution = true
  allows_deletions                = false
  allows_force_pushes             = false

  # Lock branch
  lock_branch = false
}

# Rulesets for additional protection
resource "github_repository_ruleset" "production_deployments" {
  count = var.enable_branch_protection ? 1 : 0

  name        = "production-deployments"
  repository  = data.github_repository.this.name
  target      = "branch"
  enforcement = "active"

  conditions {
    ref_name {
      include = ["refs/heads/main"]
      exclude = []
    }
  }

  rules {
    # Require linear history
    required_linear_history = true

    # Require deployments to succeed
    required_deployments {
      required_deployment_environments = ["production"]
    }

    # Pull request requirements
    pull_request {
      required_approving_review_count   = var.required_approvals
      dismiss_stale_reviews_on_push     = true
      require_code_owner_review         = true
      require_last_push_approval        = true
      required_review_thread_resolution = true
    }
  }
}

# Tag protection for releases
resource "github_repository_tag_protection" "releases" {
  repository = data.github_repository.this.name
  pattern    = "v*"
}
