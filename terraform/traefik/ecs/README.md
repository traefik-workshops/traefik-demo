# traefik/ecs

Provisions Traefik Hub on AWS ECS, wiring in `traefik/shared` (config extraction) and `compute/aws/ecs` (service deployment).

## Example usage

```hcl
module "traefik" {
  source = "git::https://github.com/traefik/traefik-demo.git//terraform/traefik/ecs?ref=v3.2.0"

  traefik_hub_token = var.traefik_hub_token
}
```

## Prerequisites

- AWS credentials with ECS/VPC permissions.
- A Traefik Hub token.

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name | Version |
|------|---------|
| aws | ~> 5.0 |

## Providers

| Name | Source | Version |
|------|--------|---------|
| aws | `hashicorp/aws` | `~> 5.0` |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cloudflare_dns 🔒 | Cloudflare DNS configuration for certificate resolver | `object({enabled = optional(bool, false), domain = optional(string, ""), api_token = optional(string, ""), extra_san_domains = optional(list(string), []))` | `{"enabled":false,"domain":"","api_token":"","extra_san_domains":[]}` | no |
| create_vpc | Create VPC if vpc_id is not provided | `bool` | `true` | no |
| custom_arguments | Additional CLI arguments for Traefik | `list(string)` | `[]` | no |
| custom_envs | Custom environment variables | `list(object({name = string, value = string))` | `[]` | no |
| custom_image_registry | Custom image registry | `string` | `""` | no |
| custom_image_repository | Custom image repository | `string` | `""` | no |
| custom_image_tag | Custom image tag | `string` | `""` | no |
| custom_plugins | Custom plugins to use for the deployment | `map(object({moduleName = string, version = string))` | `{}` | no |
| custom_ports | Custom ports configuration | `map(object({port = number, protocol = optional(string, "tcp")))` | `{}` | no |
| dashboard_entrypoints | Dashboard entry points | `list(string)` | `["traefik"]` | no |
| dashboard_insecure | Enable insecure dashboard access (no auth) | `bool` | `true` | no |
| dashboard_match_rule | Match rule for the Traefik dashboard router | `string` | `""` | no |
| enable_access_logs | Enable Traefik access logs | `bool` | `true` | no |
| enable_ai_gateway | Enable Traefik Hub AI Gateway features | `bool` | `false` | no |
| enable_api_gateway | Enable Traefik Hub API Gateway features | `bool` | `false` | no |
| enable_dashboard | Enable Traefik dashboard | `bool` | `true` | no |
| enable_debug | Enable Traefik debug mode (pprof) | `bool` | `false` | no |
| enable_mcp_gateway | Enable MCP Gateway (Claude, etc.) | `bool` | `false` | no |
| enable_offline_mode | Enable Traefik Hub Offline mode | `bool` | `false` | no |
| enable_otlp_access_logs | Enable OTLP access logs | `bool` | `false` | no |
| enable_otlp_application_logs | Enable OTLP application logs | `bool` | `false` | no |
| enable_otlp_metrics | Enable OTLP metrics | `bool` | `false` | no |
| enable_otlp_traces | Enable OTLP traces | `bool` | `false` | no |
| enable_preview_mode | Enable Traefik Hub Preview features | `bool` | `false` | no |
| enable_prometheus | Enable Prometheus metrics | `bool` | `false` | no |
| extra_labels | Extra labels to apply to the ECS task | `map(string)` | `{}` | no |
| file_provider_config | YAML configuration for Traefik file provider | `string` | `""` | no |
| file_provider_path | Path where the file provider config is mounted | `string` | `"/etc/traefik/dynamic"` | no |
| is_staging_letsencrypt | Use Let's Encrypt staging environment | `bool` | `false` | no |
| log_level | Log level (DEBUG, INFO, WARN, ERROR) | `string` | `"INFO"` | no |
| multicluster_provider | Traefik Hub multicluster provider configuration | `object({enabled = optional(bool, false), pollInterval = optional(number, null), pollTimeout = optional(number, null), children = optional(any, {))` | `{"enabled":false}` | no |
| nutanix_provider 🔒 | Nutanix Prism Central provider configuration for VM discovery | `object({enabled = optional(bool, false), endpoint = optional(string, ""), username = optional(string, ""), password = optional(string, ""), api_key = optional(string, ""), insecure_skip_verify = optional(bool, false), poll_interval = optional(string, "30s"), poll_timeout = optional(string, "5s"))` | `{"enabled":false}` | no |
| otlp_address | OTLP collector endpoint | `string` | `""` | no |
| otlp_service_name | Service name for telemetry | `string` | `"traefik"` | no |
| replica_count | Number of replicas (ECS tasks) | `number` | `1` | no |
| security_group_ids | List of security group IDs for ECS tasks | `list(string)` | `[]` | no |
| subnet_ids | List of subnet IDs for ECS tasks | `list(string)` | `[]` | no |
| traefik_chart_version | Traefik Helm chart version | `string` | `"38.0.1"` | no |
| traefik_hub_preview_tag | Traefik Hub preview version tag | `string` | `""` | no |
| traefik_hub_tag | Traefik Hub version tag | `string` | `"v3.19.0"` | no |
| traefik_hub_token 🔒 | Traefik Hub license token | `string` | `""` | no |
| traefik_tag | Traefik OSS version tag | `string` | `"v3.6.6"` | no |
| vpc_id | VPC ID for ECS resources | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| services | Map of ECS services with their details |

<!-- END_TF_DOCS -->
