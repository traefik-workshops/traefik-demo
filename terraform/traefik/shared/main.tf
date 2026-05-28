# =============================================================================
# traefik/shared - Main Configuration Module
# =============================================================================
# Generates Helm values and optionally extracts config for VM deployments.
# - K8s: Uses helm_values output directly
# - EC2/ECS/Nutanix: Uses extracted CLI args, env vars, etc.
#
# This file holds only the small computed scalars + the extract-config data
# source. The bulk lives in:
#   - helm_values.tf  → the helm_values map (source of truth for K8s)
#   - cli_args.tf     → additionalArguments built from feature flags
#   - env.tf          → environment variables built from feature flags
# =============================================================================

locals {
  # ---------------------------------------------------------------------------
  # Computed Image Configuration
  # ---------------------------------------------------------------------------
  image_registry = (
    var.custom_image_registry != "" ? var.custom_image_registry :
    var.enable_preview_mode ? "europe-west9-docker.pkg.dev/traefiklabs" :
    var.enable_api_gateway ? "ghcr.io" : ""
  )

  image_repository = (
    var.custom_image_repository != "" ? var.custom_image_repository :
    var.enable_preview_mode ? "traefik-hub/traefik-hub" :
    var.enable_api_gateway ? "traefik/traefik-hub" : "traefik"
  )

  image_tag = (
    var.custom_image_tag != "" ? var.custom_image_tag :
    var.enable_preview_mode && var.traefik_hub_preview_tag != "" ? var.traefik_hub_preview_tag :
    var.enable_preview_mode ? "latest-v3" :
    var.enable_api_gateway ? var.traefik_hub_tag : var.traefik_tag
  )

  image_full = "${local.image_registry != "" ? "${local.image_registry}/" : ""}${local.image_repository}:${local.image_tag}"

  # ---------------------------------------------------------------------------
  # Let's Encrypt Configuration
  # ---------------------------------------------------------------------------
  letsencrypt_server = var.is_staging_letsencrypt ? "https://acme-staging-v02.api.letsencrypt.org/directory" : "https://acme-v02.api.letsencrypt.org/directory"

  # ---------------------------------------------------------------------------
  # OTLP Endpoint
  # ---------------------------------------------------------------------------
  otlp_endpoint = var.otlp_address != "" ? var.otlp_address : "http://opentelemetry-collector:4318"

  # ---------------------------------------------------------------------------
  # DNS Domain Configuration
  # ---------------------------------------------------------------------------
  dns_domain = var.dns_traefiker.enabled ? var.dns_traefiker.domain : var.cloudflare_dns.domain

  # ---------------------------------------------------------------------------
  # Helm values with null top-level keys filtered out.
  # Consumed by both the `helm_values*` outputs and the extract_config data source.
  # ---------------------------------------------------------------------------
  helm_values_clean = { for k, v in local.helm_values : k => v if v != null }
}

# Extract config using helm template (for VM deployments)
data "external" "helm_config" {
  count   = var.extract_config ? 1 : 0
  program = ["bash", "${path.module}/scripts/extract_config.sh"]

  query = {
    values_yaml   = yamlencode(local.helm_values_clean)
    chart_version = var.traefik_chart_version
  }
}

# Variable to control extraction
variable "extract_config" {
  description = "Whether to run helm template extraction (for EC2/ECS/Nutanix)"
  type        = bool
  default     = false
}
