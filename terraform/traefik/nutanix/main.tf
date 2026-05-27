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

  # Extract ports from entry points
  ports_to_open = [
    for ep in module.config.entry_points :
    replace(ep.address, ":", "")
  ]

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
