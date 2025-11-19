package spacelift

# Cost Estimation Policy
# Warns if the estimated monthly cost exceeds thresholds
# Denies deployments exceeding critical thresholds

# Default is to allow (no cost data = allow)
deny[sprintf("cost estimate unavailable - please review manually")] {
    not input.third_party_metadata.custom.cost_estimation
}

# Warn if monthly cost estimate exceeds warning threshold
warn[sprintf("estimated monthly cost ($%.2f) exceeds warning threshold ($%.2f)", [monthly_cost, warning_threshold])] {
    monthly_cost := to_number(input.third_party_metadata.custom.cost_estimation.monthly_cost)
    warning_threshold := 1000
    monthly_cost > warning_threshold
    monthly_cost <= 5000
}

# Deny if monthly cost estimate exceeds critical threshold
deny[sprintf("estimated monthly cost ($%.2f) exceeds critical threshold ($%.2f) - requires manual approval", [monthly_cost, critical_threshold])] {
    monthly_cost := to_number(input.third_party_metadata.custom.cost_estimation.monthly_cost)
    critical_threshold := 5000
    monthly_cost > critical_threshold
}

# Warn on significant cost increase (>50%)
warn[sprintf("cost increase of %.0f%% detected (from $%.2f to $%.2f)", [increase_pct, previous_cost, current_cost])] {
    current_cost := to_number(input.third_party_metadata.custom.cost_estimation.monthly_cost)
    previous_cost := to_number(input.third_party_metadata.custom.cost_estimation.previous_monthly_cost)
    previous_cost > 0
    increase_pct := ((current_cost - previous_cost) / previous_cost) * 100
    increase_pct > 50
}

# Sample run to always include in plan
sample { true }
