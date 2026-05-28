output "transit_dashboard_url" {
  description = "Transit cluster's Traefik dashboard."
  value       = "https://dashboard.${var.domain}"
}

output "whoami_url" {
  description = "Whoami workload — served by app-workload cluster, routed through transit."
  value       = "https://whoami.${var.domain}"
}
