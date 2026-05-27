# traefik/shared

Helm-template-extraction module that renders the upstream Traefik Helm chart and exposes the CLI args, env vars, ports, image refs, and static config as outputs. Consumed by `traefik/ec2`, `traefik/ecs`, `traefik/k8s`, and `traefik/nutanix` so they all agree on what Traefik configuration looks like.

## Example usage

Consumed internally by the other `traefik/*` modules; rarely instantiated directly. If you do:

```hcl
module "traefik_config" {
  source = "git::https://github.com/traefik/terraform-demo-modules.git//terraform/traefik/shared?ref=v3.2.0"

  traefik_hub_token = var.traefik_hub_token
  cloudflare_dns    = var.cloudflare_dns
}
```

## Prerequisites

- A Traefik Hub token.
- Local `helm` binary if `extract_config = true` (the module shells out to `helm template`).

## Notes

- See PROV-01 in [../../ISSUES.md](../../ISSUES.md) — this module is missing `required_providers`.

<!-- BEGIN_TF_DOCS -->

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cloudflare_dns 🔒 | Cloudflare DNS configuration for certificate resolver | `object({enabled = optional(bool, false), domain = optional(string, ""), api_token = optional(string, ""), extra_san_domains = optional(list(string), []))` | `{"enabled":false,"domain":"","api_token":"","extra_san_domains":[]}` | no |
| custom_arguments | Additional CLI arguments for Traefik | `list(string)` | `[]` | no |
| custom_envs | Custom environment variables | `list(object({name = string, value = string))` | `[]` | no |
| custom_image_registry | Custom image registry | `string` | `""` | no |
| custom_image_repository | Custom image repository | `string` | `""` | no |
| custom_image_tag | Custom image tag | `string` | `""` | no |
| custom_plugins | Custom plugins to use for the deployment | `map(object({moduleName = string, version = string))` | `{}` | no |
| custom_ports | Custom ports configuration | `any` | `{}` | no |
| dashboard_entrypoints | Entrypoints for the Traefik dashboard | `list(string)` | `["traefik"]` | no |
| dashboard_insecure | Enable insecure dashboard access (no auth) | `bool` | `false` | no |
| dashboard_match_rule | Match rule for the Traefik dashboard router | `string` | `""` | no |
| dns_traefiker | DNS Traefiker configuration for automatic domain registration | `object({enabled = optional(bool, false), chart = optional(string, ""), unique_domain = optional(bool, false), domain = optional(string, ""), enable_airlines_subdomain = optional(bool, false), ip_override = optional(string, ""), proxied = optional(bool, false))` | `{"enabled":false}` | no |
| enable_access_logs | Enable Traefik access logs | `bool` | `true` | no |
| enable_ai_gateway | Enable Traefik Hub AI Gateway features | `bool` | `false` | no |
| enable_api_gateway | Enable Traefik Hub API Gateway features | `bool` | `false` | no |
| enable_api_management | Enable Traefik Hub API Management features (K8s only) | `bool` | `false` | no |
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
| entry_points | Entry points configuration | `map(object({address = string, port = optional(number), protocol = optional(string, "TCP")))` | `{"web":{"address":":80","port":80},"websecure":{"address":":443","port":443},"traefik":{"address":":8080","port":8080}}` | no |
| extract_config | Whether to run helm template extraction (for EC2/ECS/Nutanix) | `bool` | `false` | no |
| file_provider_config | YAML content for Traefik file provider dynamic configuration | `string` | `""` | no |
| file_provider_path | Path where the file provider config is mounted (platform-specific) | `string` | `"/file-provider"` | no |
| is_staging_letsencrypt | Use Let's Encrypt staging environment | `bool` | `false` | no |
| log_level | Log level (DEBUG, INFO, WARN, ERROR) | `string` | `"INFO"` | no |
| multicluster_provider | Traefik Hub multicluster provider configuration | `object({enabled = optional(bool, false), pollInterval = optional(number, null), pollTimeout = optional(number, null), children = optional(any, {))` | `{"enabled":false}` | no |
| nutanix_provider 🔒 | Nutanix Prism Central provider configuration for VM discovery | `object({enabled = optional(bool, false), endpoint = optional(string, ""), username = optional(string, ""), password = optional(string, ""), api_key = optional(string, ""), insecure_skip_verify = optional(bool, false), poll_interval = optional(string, "30s"), poll_timeout = optional(string, "5s"), filename = optional(string, ""))` | `{"enabled":false}` | no |
| otlp_address | OTLP collector endpoint | `string` | `""` | no |
| otlp_service_name | Service name for telemetry | `string` | `"traefik"` | no |
| replica_count | Number of replicas (VMs, EC2 instances, ECS tasks, K8s pods) | `number` | `1` | no |
| traefik_chart_version | Traefik Helm chart version | `string` | `"38.0.1"` | no |
| traefik_hub_preview_tag | Traefik Hub preview version tag | `string` | `""` | no |
| traefik_hub_tag | Traefik Hub version tag | `string` | `"v3.19.0"` | no |
| traefik_hub_token 🔒 | Traefik Hub license token | `string` | `""` | no |
| traefik_tag | Traefik OSS version tag | `string` | `"v3.6.6"` | no |
| use_distributed_acme | Use distributedAcme instead of acme (stores certs in K8s secrets instead of acme.json file) | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| cli_arguments | Additional CLI arguments (from Helm values additionalArguments) |
| cloudflare_dns 🔒 | Cloudflare DNS configuration |
| computed_dashboard_match_rule | Computed dashboard match rule |
| computed_dns_domain | Computed DNS domain (from dns_traefiker or cloudflare_dns) |
| custom_plugins | n/a |
| dashboard_entrypoints | Dashboard entrypoints |
| dashboard_match_rule | Dashboard match rule |
| enable_ai_gateway | n/a |
| enable_api_gateway | n/a |
| enable_api_management | n/a |
| enable_mcp_gateway | n/a |
| enable_offline_mode | n/a |
| enable_otlp_access_logs | n/a |
| enable_otlp_application_logs | n/a |
| enable_otlp_metrics | n/a |
| enable_otlp_traces | n/a |
| enable_preview_mode | n/a |
| enable_prometheus | n/a |
| entry_points | Entry points configuration |
| env_vars_list 🔒 | Environment variables as list (from Helm values env) |
| extracted_cli_args | CLI arguments extracted from rendered Helm chart |
| extracted_cli_args_cloud | CLI arguments extraction filtered for cloud/VM environments (excludes Kubernetes providers) |
| extracted_env_vars 🔒 | Environment variables extracted from rendered Helm chart (as JSON string) |
| extracted_image | Full image reference extracted from rendered Helm chart |
| extracted_static_config | Static configuration YAML extracted from rendered Helm chart |
| extracted_volume_mounts | Volume mounts extracted from rendered Helm chart (as JSON string) |
| extracted_volumes | Volumes extracted from rendered Helm chart (as JSON string) |
| helm_values 🔒 | Helm values as a map (for K8s helm_release) |
| helm_values_yaml 🔒 | Helm values as YAML string |
| image_config | Image configuration object |
| image_full | Computed full image reference |
| image_tag | Computed image tag |
| letsencrypt_server | Let's Encrypt ACME server URL |
| log_level | Log level |
| otlp_endpoint | OTLP endpoint URL |
| ports 🔒 | Ports configuration (from Helm values ports) |
| ports_list | Flat list of port numbers for Docker/VM port mappings |
| replica_count | Number of replicas |
| traefik_hub_tag | Traefik Hub version tag |
| traefik_hub_token 🔒 | Traefik Hub license token |

<!-- END_TF_DOCS -->
