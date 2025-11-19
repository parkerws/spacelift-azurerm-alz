output "premium_firewall_id" {
  description = "The ID of the Premium Azure Firewall"
  value       = module.firewall_premium.id
}

output "premium_firewall_private_ip" {
  description = "The private IP of the Premium Azure Firewall"
  value       = module.firewall_premium.private_ip_address
}

output "premium_firewall_public_ips" {
  description = "All public IPs of the Premium Azure Firewall"
  value       = module.firewall_premium.public_ip_addresses
}

output "forced_tunnel_firewall_id" {
  description = "The ID of the forced tunneling firewall"
  value       = module.firewall_forced_tunnel.id
}

output "explicit_ips_firewall_id" {
  description = "The ID of the firewall with explicit IP configurations"
  value       = module.firewall_explicit_ips.id
}

output "all_firewall_ids" {
  description = "All firewall IDs created in this example"
  value = {
    premium         = module.firewall_premium.id
    forced_tunnel   = module.firewall_forced_tunnel.id
    explicit_ips    = module.firewall_explicit_ips.id
  }
}

output "premium_firewall_details" {
  description = "Detailed information about the Premium firewall"
  value = {
    name             = module.firewall_premium.name
    private_ip       = module.firewall_premium.private_ip_address
    public_ips       = module.firewall_premium.public_ip_addresses
    sku_tier         = module.firewall_premium.sku_tier
    zones            = module.firewall_premium.zones
    threat_intel     = module.firewall_premium.threat_intel_mode
  }
}
