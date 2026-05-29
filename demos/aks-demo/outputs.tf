output "domain" {
  value       = var.domain
  description = "Base demo domain (scenarios.sh reads this)."
}

output "portal_url" {
  value       = "https://portal.${var.domain}"
  description = "Traefik Hub API Portal — sign in with Keycloak SSO (developer / password)."
}

output "keycloak_url" {
  value       = "https://keycloak.${var.domain}"
  description = "Keycloak UI (admin: traefik / topsecretpassword)."
}

output "whoami_url" {
  value       = "https://whoami.${var.domain}"
  description = "The whoami API — 401 without a JWT, 200 with a Keycloak Bearer token."
}

output "grafana_url" {
  value       = "https://grafana.${var.domain}"
  description = "Grafana — Traefik metrics (Prometheus) + access logs (Loki) via the OTel collector."
}

output "langfuse_url" {
  value       = "https://langfuse.${var.domain}"
  description = "Langfuse UI — Traefik traces via the OTel collector."
}

output "dashboard_url" {
  value       = "https://dashboard.${var.domain}"
  description = "Traefik Hub dashboard."
}

output "developer_jwt" {
  value       = module.keycloak.users_map["developer"].access_token
  description = "A ready-to-use Keycloak access token for the seeded `developer` user (Authorization: Bearer ...). Handy for curling the whoami API."
  sensitive   = true
}

output "langfuse_admin" {
  value       = "${module.langfuse.admin_user_email} / ${nonsensitive(module.langfuse.admin_user_password)}"
  description = "Langfuse UI login."
}
