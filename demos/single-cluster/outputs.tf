output "dashboard_url" {
  description = "Traefik dashboard URL."
  value       = "https://dashboard.${var.domain}"
}

output "whoami_url" {
  description = "Sample workload URL — should return whoami JSON when the cluster + Traefik are ready."
  value       = "https://whoami.${var.domain}"
}
