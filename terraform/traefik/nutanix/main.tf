# =============================================================================
# Nutanix VM Traefik Deployment
# =============================================================================
# Uses extracted config from traefik/shared module (via Helm template).
# =============================================================================

locals {
  # CLI arguments from shared module
  cli_arguments = concat(
    module.config.extracted_cli_args_cloud,
    [
      "--providers.file.directory=/etc/traefik-hub/dynamic",
      "--providers.file.watch=true"
    ]
  )

  # Dashboard configuration
  dashboard_config = var.enable_dashboard ? yamlencode({
    http = {
      routers = {
        dashboard = {
          rule        = module.config.computed_dashboard_match_rule
          service     = "api@internal"
          entryPoints = var.dashboard_entrypoints
          tls = (var.cloudflare_dns.enabled || var.dns_traefiker.enabled) ? {
            certResolver = "cf"
          } : {}
        }
      }
    }
  }) : ""

  # Traefik instances tagged for service discovery (always enabled with defaults)
  traefik_categories = {
    "TraefikServiceName" = "traefik"
    "TraefikServicePort" = "80"
  }

  # Normalize performance tuning with defaults (consistent with EC2)
  performance_tuning = {
    limit_nofile        = coalesce(try(var.performance_tuning.limit_nofile, null), 500000)
    tcp_tw_reuse        = coalesce(try(var.performance_tuning.tcp_tw_reuse, null), 1)
    tcp_timestamps      = coalesce(try(var.performance_tuning.tcp_timestamps, null), 1)
    rmem_max            = coalesce(try(var.performance_tuning.rmem_max, null), 16777216)
    wmem_max            = coalesce(try(var.performance_tuning.wmem_max, null), 16777216)
    somaxconn           = coalesce(try(var.performance_tuning.somaxconn, null), 4096)
    netdev_max_backlog  = coalesce(try(var.performance_tuning.netdev_max_backlog, null), 4096)
    ip_local_port_range = coalesce(try(var.performance_tuning.ip_local_port_range, null), "1024 65535")
    gomaxprocs          = coalesce(try(var.performance_tuning.gomaxprocs, null), 0)
    gogc                = coalesce(try(var.performance_tuning.gogc, null), 100)
    numa_node           = coalesce(try(var.performance_tuning.numa_node, null), -1)
  }
}

# Use shared cloud-init module
module "cloud_init" {
  source = "../cloud-init"

  traefik_hub_version = module.config.traefik_hub_tag
  arch                = var.arch
  cli_arguments       = local.cli_arguments
  env_vars = concat(
    module.config.env_vars_list,
    [{ name = "HUB_TOKEN", value = var.traefik_hub_token }]
  )
  file_provider_config = var.file_provider_config
  dashboard_config     = local.dashboard_config
  extra_files          = var.extra_files
  performance_tuning   = local.performance_tuning
  vip                  = var.vip
  keepalived_priority  = var.keepalived_priority
  network_interface    = var.network_interface
  dns_traefiker        = var.dns_traefiker
  enable_preview_mode  = var.enable_preview_mode
  preview_image        = module.config.image_full
}

module "traefik_vm" {
  source = "../../compute/nutanix/vm"

  name                 = var.vm_name
  cluster_uuid         = var.cluster_id
  subnet_uuid          = var.subnet_uuid
  image_uuid           = var.image_id
  num_vcpus_per_socket = var.vm_num_vcpus_per_socket
  num_sockets          = var.vm_num_sockets
  memory_size_mib      = var.vm_memory_mib
  disk_size_mib        = var.vm_disk_size_mib
  static_ip            = var.vm_static_ip

  categories = local.traefik_categories

  cloud_init_user_data = module.cloud_init.rendered
}

# =============================================================================
# Shared Configuration Module - Nutanix
# =============================================================================
# Nutanix uses extracted config from helm template (extract_config=true).
# Shared variables are defined here alongside the module instantiation.
# =============================================================================

module "config" {
  source = "../shared"

  # Extract config - Nutanix needs CLI args, env vars from Helm template
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
  dns_traefiker          = var.dns_traefiker
  is_staging_letsencrypt = var.is_staging_letsencrypt

  # Dashboard
  enable_dashboard      = var.enable_dashboard
  dashboard_insecure    = var.dashboard_insecure
  dashboard_entrypoints = var.dashboard_entrypoints
  dashboard_match_rule  = var.dashboard_match_rule

  # Entry Points (for Nutanix VM static config)
  entry_points = {
    for k, v in var.entry_points : k => {
      address = v.address
      port    = tonumber(replace(v.address, ":", ""))
    }
  }

  # Providers
  multicluster_provider = var.multicluster_provider
  nutanix_provider      = var.nutanix_provider
}
