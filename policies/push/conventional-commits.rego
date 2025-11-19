package spacelift

# Conventional Commits Policy
# Enforces conventional commit message format
# Format: <type>(<scope>): <description>

# Valid commit types
valid_types := [
    "feat",     # New feature
    "fix",      # Bug fix
    "docs",     # Documentation changes
    "style",    # Code style changes (formatting, etc.)
    "refactor", # Code refactoring
    "perf",     # Performance improvements
    "test",     # Adding or updating tests
    "chore",    # Maintenance tasks
    "ci",       # CI/CD changes
    "build",    # Build system changes
    "revert"    # Revert previous commit
]

# Check if commit message follows conventional format
# Pattern: type(scope): description
# Or: type: description
is_conventional(message) {
    # Match: type(scope): description
    regex.match(`^(feat|fix|docs|style|refactor|perf|test|chore|ci|build|revert)(\([a-z0-9-]+\))?: .+`, message)
}

# Extract commit type from message
commit_type(message) = type {
    parts := regex.find_all_string_submatch_n(`^([a-z]+)`, message, 1)
    count(parts) > 0
    type := parts[0][1]
}

# Check if the push includes proper commit messages
ignore {
    # Ignore merge commits
    contains(input.push.head.message, "Merge")
}

ignore {
    # Ignore dependency update commits
    startswith(input.push.head.message, "chore(deps)")
}

# Deny pushes with non-conventional commit messages
deny[msg] {
    not ignore
    message := input.push.head.message
    not is_conventional(message)
    msg := sprintf("commit message does not follow conventional commits format: '%s'\nExpected: <type>(<scope>): <description>\nValid types: %v", [
        message,
        valid_types
    ])
}

# Deny if commit type is invalid
deny[msg] {
    not ignore
    message := input.push.head.message
    type := commit_type(message)
    not type in valid_types
    msg := sprintf("invalid commit type '%s' - must be one of: %v", [type, valid_types])
}

# Warn if commit message is too short
warn[msg] {
    not ignore
    message := input.push.head.message
    count(message) < 20
    msg := sprintf("commit message is very short (%d chars) - consider adding more context", [count(message)])
}

# Warn if commit message is too long
warn[msg] {
    not ignore
    message := input.push.head.message
    first_line := split(message, "\n")[0]
    count(first_line) > 100
    msg := sprintf("commit message first line is too long (%d chars) - should be under 100", [count(first_line)])
}

sample { true }
