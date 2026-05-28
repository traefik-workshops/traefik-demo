# =============================================================================
# Shared Configuration Module - K8s
# =============================================================================
# K8s uses helm_values directly (no extraction needed).
# Shared variables are defined here alongside the module instantiation.
# =============================================================================

module "config" {
  source = "../shared"

  # Don't extract config - K8s uses Helm values directly
  extract_config = false

  # Feature Flags
  enable_api_gateway    = var.enable_api_gateway
  enable_ai_gateway     = var.enable_ai_gateway
  enable_mcp_gateway    = var.enable_mcp_gateway
  enable_api_management = var.enable_api_management
  enable_offline_mode   = var.enable_offline_mode
  enable_preview_mode   = var.enable_preview_mode
  enable_debug          = var.enable_debug

  # Replica count
  replica_count = var.replica_count

  # Versions & Images
  traefik_chart_version   = var.traefik_chart_version
  traefik_tag             = var.traefik_tag
  traefik_hub_tag         = var.traefik_hub_tag
  traefik_hub_preview_tag = var.traefik_hub_preview_tag
  custom_image_registry   = var.custom_image_registry
  custom_image_repository = var.custom_image_repository
  custom_image_tag        = var.custom_image_tag

  # Observability
  log_level                    = var.log_level
  otlp_address                 = var.otlp_address
  otlp_service_name            = var.otlp_service_name
  enable_otlp_access_logs      = var.enable_otlp_access_logs
  enable_otlp_application_logs = var.enable_otlp_application_logs
  enable_otlp_metrics          = var.enable_otlp_metrics
  enable_otlp_traces           = var.enable_otlp_traces
  enable_prometheus            = var.enable_prometheus
  enable_access_logs           = var.enable_access_logs

  # Plugins & Extensions
  custom_plugins       = var.custom_plugins
  custom_ports         = var.custom_ports
  custom_arguments     = var.custom_arguments
  custom_envs          = var.custom_envs
  file_provider_config = var.file_provider_config
  file_provider_path   = var.file_provider_path

  # Licensing & DNS
  traefik_hub_token = var.traefik_hub_token
  cloudflare_dns    = var.cloudflare_dns
  dns_traefiker = {
    enabled                   = var.dns_traefiker.enabled
    chart                     = var.dns_traefiker.chart
    unique_domain             = var.dns_traefiker.unique_domain
    domain                    = var.dns_traefiker.unique_domain && length(data.kubernetes_secret_v1.dns_domain) > 0 ? data.kubernetes_secret_v1.dns_domain[0].data["domain"] : var.dns_traefiker.domain
    enable_airlines_subdomain = var.dns_traefiker.enable_airlines_subdomain
    ip_override               = var.dns_traefiker.ip_override
    proxied                   = var.dns_traefiker.proxied
  }
  is_staging_letsencrypt = var.is_staging_letsencrypt
  use_distributed_acme   = var.use_distributed_acme

  # Dashboard
  enable_dashboard      = var.enable_dashboard
  dashboard_insecure    = var.dashboard_insecure
  dashboard_entrypoints = var.dashboard_entrypoints
  dashboard_match_rule  = var.dashboard_match_rule
  # Providers
  multicluster_provider = var.multicluster_provider
  nutanix_provider      = var.nutanix_provider

}
