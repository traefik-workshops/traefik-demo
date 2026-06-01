output "domain" {
  value       = var.domain
  description = "Base demo domain. scenarios.sh reads this to build the test URLs."
}

output "dashboard_url" {
  value       = "https://dashboard.${var.domain}"
  description = "Traefik Hub dashboard on the EKS hub."
}

# --- Workloads through the unified ingress ------------------------------------
output "whoami_url" {
  value       = "https://whoami.${var.domain}"
  description = "whoami on the EKS hub — a managed API: 401 without a JWT, 200 with a Keycloak Bearer token."
}

output "legacy_nginx_url" {
  value       = "https://legacy.${var.domain}"
  description = "whoami from a native nginx Ingress via Traefik's kubernetesIngressNGINX provider (the NGINX -> Traefik migration)."
}

output "aks_whoami_url" {
  value       = "https://aks.${var.domain}"
  description = "whoami on the AKS spoke, via the EKS hub over the SPIFFE-mTLS multicluster uplink."
}

output "ec2_whoami_url" {
  value       = "https://ec2.${var.domain}"
  description = "whoami on the EC2 spoke (VM), via the EKS hub uplink."
}

output "ecs_whoami_url" {
  value       = "https://ecs.${var.domain}"
  description = "whoami on the ECS spoke (Fargate), via the EKS hub uplink."
}

# --- AI / MCP gateway (on AKS) ------------------------------------------------
output "ai_url" {
  value       = "https://ai.${var.domain}/v1/chat/completions"
  description = "AI gateway on AKS (content guards + token rate-limit), fronted by the hub. POST a chat-completion; PII/email prompts are blocked at the gateway."
}

output "mcp_url" {
  value       = "https://mcp.${var.domain}"
  description = "MCP inspector on AKS, fronted by the hub."
}

# --- API Management + portal --------------------------------------------------
output "portal_url" {
  value       = "https://portal.${var.domain}"
  description = "Traefik Hub API Portal — sign in with Keycloak SSO."
}

output "keycloak_url" {
  value       = "https://keycloak.${var.domain}"
  description = "Keycloak UI / OIDC issuer."
}

output "developer_jwt" {
  value       = module.keycloak.users_map["developer"].access_token
  description = "Ready-to-use Keycloak access token for the seeded `developer` user (Authorization: Bearer ...). scenarios.sh reads this to exercise the whoami API gate."
  sensitive   = true
}

# --- WAF / mirroring / failover -----------------------------------------------
output "waf_url" {
  value       = "https://waf.${var.domain}"
  description = "WAF-protected route (Coraza/OWASP CRS): SQLi/XSS -> 403, benign -> 200."
}

output "mirror_url" {
  value       = "https://mirror.${var.domain}"
  description = "Mirrored route — served by the hub whoami and shadow-copied to a second whoami."
}

output "failover_url" {
  value       = "https://failover.${var.domain}"
  description = "Cross-cluster failover route — AKS primary, hub-local whoami fallback."
}

# --- Observability ------------------------------------------------------------
output "grafana_url" {
  value       = "https://grafana.${var.domain}"
  description = "Grafana — Traefik metrics (Prometheus) + access logs (Loki) via the OTel collector."
}

output "langfuse_url" {
  value       = "https://langfuse.${var.domain}"
  description = "Langfuse UI — Traefik + AI-gateway traces via the OTel collector."
}
