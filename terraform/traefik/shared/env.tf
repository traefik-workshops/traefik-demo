# =============================================================================
# Environment variables for the Traefik container.
# =============================================================================
# Wired into helm_values.env (see helm_values.tf).
# =============================================================================

locals {
  env_vars = concat(
    var.cloudflare_dns.enabled ? [
      { name = "CF_DNS_API_TOKEN", value = var.cloudflare_dns.api_token }
    ] : [],
    var.custom_envs
  )
}
