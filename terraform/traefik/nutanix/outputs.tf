output "ip_address" {
  description = "Ip address."
  value       = module.traefik_vm.ip_address
}

output "dashboard_url" {
  description = "The Traefik dashboard URL"
  value       = "https://dashboard.${module.config.computed_dns_domain}"
}
