output "active_active_gateway_id" {
  description = "The ID of the active-active VPN Gateway"
  value       = module.vpn_gateway_active_active.id
}

output "p2s_gateway_id" {
  description = "The ID of the Point-to-Site VPN Gateway"
  value       = module.vpn_gateway_p2s.id
}

output "aad_gateway_id" {
  description = "The ID of the Azure AD authenticated VPN Gateway"
  value       = module.vpn_gateway_aad.id
}

output "high_perf_gateway_id" {
  description = "The ID of the high-performance VPN Gateway"
  value       = module.vpn_gateway_high_perf.id
}

output "all_gateway_ids" {
  description = "All VPN Gateway IDs created in this example"
  value = {
    active_active = module.vpn_gateway_active_active.id
    p2s           = module.vpn_gateway_p2s.id
    aad           = module.vpn_gateway_aad.id
    high_perf     = module.vpn_gateway_high_perf.id
  }
}

output "active_active_details" {
  description = "Details of the active-active VPN Gateway"
  value = {
    name           = module.vpn_gateway_active_active.name
    public_ips     = module.vpn_gateway_active_active.public_ip_addresses
    active_active  = module.vpn_gateway_active_active.active_active
    bgp_enabled    = module.vpn_gateway_active_active.enable_bgp
    bgp_settings   = module.vpn_gateway_active_active.bgp_settings
  }
}
