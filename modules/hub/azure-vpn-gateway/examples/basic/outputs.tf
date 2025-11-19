output "vpn_gateway_id" {
  description = "The ID of the VPN Gateway"
  value       = module.vpn_gateway.id
}

output "vpn_gateway_name" {
  description = "The name of the VPN Gateway"
  value       = module.vpn_gateway.name
}

output "vpn_gateway_public_ips" {
  description = "The public IP addresses of the VPN Gateway"
  value       = module.vpn_gateway.public_ip_addresses
}
