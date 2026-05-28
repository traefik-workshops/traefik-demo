# =============================================================================
# ECS Traefik Deployment
# =============================================================================
# Uses extracted config from traefik/shared module (via Helm template).
# =============================================================================

locals {
  # Use extracted CLI arguments from Helm template
  # Uses centralized filtering to exclude Kubernetes-specific args
  traefik_arguments = module.config.extracted_cli_args_cloud

  # Use shared module for image reference
  traefik_image = module.config.image_full

  # Build Docker labels including ports
  docker_labels = merge(var.extra_labels, {
    for name, port in module.config.ports :
    "traefik.http.routers.${name}.entrypoints" => name
    if try(port.expose.default, false)
    }, {
    "traefik.enable"                                           = "true"
    "traefik.http.routers.dashboard.rule"                      = module.config.dashboard_match_rule
    "traefik.http.routers.dashboard.entrypoints"               = module.config.dashboard_entrypoints[0]
    "traefik.http.services.dashboard.loadbalancer.server.port" = "8080"
  })
}

module "ecs" {
  source = "../../compute/aws/ecs"

  name = "traefik"
  clusters = {
    traefik = {
      apps = {
        traefik = {
          replicas           = module.config.replica_count
          port               = 80
          docker_image       = local.traefik_image
          docker_command     = join(" ", local.traefik_arguments)
          subnet_ids         = var.subnet_ids
          security_group_ids = var.security_group_ids
          labels             = local.docker_labels
        }
      }
    }
  }

  create_vpc = var.create_vpc
  vpc_id     = var.vpc_id
}

# =============================================================================
# Shared Configuration Module - ECS
# =============================================================================
# ECS uses extracted config from helm template (extract_config=true).
# Shared variables are defined here alongside the module instantiation.
# =============================================================================

module "config" {
  source = "../shared"

  # Extract config - ECS needs CLI args, env vars from Helm template
  extract_config = true

  # Feature Flags
  enable_api_gateway    = var.enable_api_gateway
  enable_ai_gateway     = var.enable_ai_gateway
  enable_mcp_gateway    = var.enable_mcp_gateway
  enable_api_management = false # K8s only
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
  traefik_hub_token      = var.traefik_hub_token
  cloudflare_dns         = var.cloudflare_dns
  is_staging_letsencrypt = var.is_staging_letsencrypt

  # Dashboard
  enable_dashboard      = var.enable_dashboard
  dashboard_insecure    = var.dashboard_insecure
  dashboard_entrypoints = var.dashboard_entrypoints
  dashboard_match_rule  = var.dashboard_match_rule

  # Providers
  multicluster_provider = var.multicluster_provider
  nutanix_provider      = var.nutanix_provider
}
