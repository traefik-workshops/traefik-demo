# =============================================================================
# Outputs
# =============================================================================
# These outputs provide configuration for consuming modules.
# - K8s: Uses helm_values, helm_values_yaml
# - EC2/ECS/Nutanix: Uses extracted cli_args, env_vars, static_config
# =============================================================================

# -----------------------------------------------------------------------------
# Helm Values (for K8s direct use)
# -----------------------------------------------------------------------------

output "helm_values" {
  description = "Helm values as a map (for K8s helm_release)"
  value       = local.helm_values_clean
  sensitive   = true
}

output "helm_values_yaml" {
  description = "Helm values as YAML string"
  value       = yamlencode(local.helm_values_clean)
  sensitive   = true
}

# -----------------------------------------------------------------------------
# Extracted Config (for EC2/ECS/Nutanix with extract_config=true)
# -----------------------------------------------------------------------------

output "extracted_cli_args" {
  description = "CLI arguments extracted from rendered Helm chart"
  value       = var.extract_config ? jsondecode(data.external.helm_config[0].result.cli_args) : []
}

output "extracted_cli_args_cloud" {
  description = "CLI arguments extraction filtered for cloud/VM environments (excludes Kubernetes providers)"
  value = [
    for arg in(var.extract_config ? jsondecode(data.external.helm_config[0].result.cli_args) : []) :
    arg if !startswith(arg, "--providers.kubernetes") && !startswith(arg, "--experimental.kubernetes") && !startswith(arg, "--hub.token")
  ]
}

output "extracted_env_vars" {
  description = "Environment variables extracted from rendered Helm chart (as JSON string)"
  value       = var.extract_config ? data.external.helm_config[0].result.env_vars : "[]"
  sensitive   = true
}

output "extracted_volume_mounts" {
  description = "Volume mounts extracted from rendered Helm chart (as JSON string)"
  value       = var.extract_config ? data.external.helm_config[0].result.volume_mounts : "[]"
}

output "extracted_volumes" {
  description = "Volumes extracted from rendered Helm chart (as JSON string)"
  value       = var.extract_config ? data.external.helm_config[0].result.volumes : "[]"
}

output "extracted_static_config" {
  description = "Static configuration YAML extracted from rendered Helm chart"
  value       = var.extract_config ? data.external.helm_config[0].result.static_config : ""
}

output "extracted_image" {
  description = "Full image reference extracted from rendered Helm chart"
  value       = var.extract_config ? data.external.helm_config[0].result.image : local.image_full
}

# -----------------------------------------------------------------------------
# Computed Config (always available - from Helm values)
# -----------------------------------------------------------------------------

output "cli_arguments" {
  description = "Additional CLI arguments (from Helm values additionalArguments)"
  value       = local.helm_values.additionalArguments
}

output "env_vars_list" {
  description = "Environment variables as list (from Helm values env)"
  value       = local.helm_values.env
  sensitive   = true
}

output "ports" {
  description = "Ports configuration (from Helm values ports)"
  value       = local.helm_values.ports
  sensitive   = true
}

output "ports_list" {
  description = "Flat list of port numbers for Docker/VM port mappings"
  value = [
    for name, port in local.helm_values.ports : port.port
    if try(port.port, null) != null
  ]
}

output "image_tag" {
  description = "Computed image tag"
  value       = local.image_tag
}

output "image_full" {
  description = "Computed full image reference"
  value       = local.image_full
}

output "image_config" {
  description = "Image configuration object"
  value = {
    registry   = local.image_registry
    repository = local.image_repository
    tag        = local.image_tag
  }
}

output "letsencrypt_server" {
  description = "Let's Encrypt ACME server URL"
  value       = local.letsencrypt_server
}

output "otlp_endpoint" {
  description = "OTLP endpoint URL"
  value       = local.otlp_endpoint
}

# -----------------------------------------------------------------------------
# Pass-through (for convenience)
# -----------------------------------------------------------------------------

output "cloudflare_dns" {
  description = "Cloudflare DNS configuration"
  value       = var.cloudflare_dns
  sensitive   = true
}

output "entry_points" {
  description = "Entry points configuration"
  value       = var.entry_points
}

output "traefik_hub_token" {
  description = "Traefik Hub license token"
  value       = var.traefik_hub_token
  sensitive   = true
}

output "traefik_hub_tag" {
  description = "Traefik Hub version tag"
  value       = var.traefik_hub_tag
}

output "log_level" {
  description = "Log level"
  value       = var.log_level
}

output "dashboard_match_rule" {
  description = "Dashboard match rule"
  value       = var.dashboard_match_rule
}

output "dashboard_entrypoints" {
  description = "Dashboard entrypoints"
  value       = var.dashboard_entrypoints
}

output "enable_api_gateway" {
  value = var.enable_api_gateway
}

output "enable_ai_gateway" {
  value = var.enable_ai_gateway
}

output "enable_mcp_gateway" {
  value = var.enable_mcp_gateway
}

output "enable_api_management" {
  value = var.enable_api_management
}

output "enable_offline_mode" {
  value = var.enable_offline_mode
}

output "enable_preview_mode" {
  value = var.enable_preview_mode
}

output "replica_count" {
  description = "Number of replicas"
  value       = var.replica_count
}

output "enable_prometheus" {
  value = var.enable_prometheus
}

output "enable_otlp_metrics" {
  value = var.enable_otlp_metrics
}

output "enable_otlp_traces" {
  value = var.enable_otlp_traces
}

output "enable_otlp_access_logs" {
  value = var.enable_otlp_access_logs
}

output "enable_otlp_application_logs" {
  value = var.enable_otlp_application_logs
}

output "custom_plugins" {
  value = var.custom_plugins
}

output "computed_dns_domain" {
  description = "Computed DNS domain (from dns_traefiker or cloudflare_dns)"
  value       = local.dns_domain
}

output "computed_dashboard_match_rule" {
  description = "Computed dashboard match rule"
  value       = local.helm_values.ingressRoute.dashboard.matchRule
}
