output "rendered" {
  value = templatefile("${path.module}/cloud-init.tpl", {
    traefik_hub_version  = var.traefik_hub_version
    arch                 = var.arch
    cli_arguments        = var.cli_arguments
    env_vars             = var.env_vars
    file_provider_config = var.file_provider_config
    extra_files          = var.extra_files
    dashboard_config     = var.dashboard_config
    performance_tuning   = var.performance_tuning
    vip                  = var.vip
    keepalived_priority  = var.keepalived_priority
    network_interface    = var.network_interface
    otlp_address         = var.otlp_address
    instance_name        = var.instance_name
    dns_traefiker        = var.dns_traefiker
    enable_preview_mode  = var.enable_preview_mode
    preview_image        = var.preview_image
  })
}
