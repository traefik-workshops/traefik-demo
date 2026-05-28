# traefik/k8s

Deploys Traefik Hub on Kubernetes via Helm, with the full feature-flag matrix (API Gateway, AI Gateway, MCP Gateway, API Management, Knative provider, etc.) wired through `traefik/shared`.

## Example usage

```hcl
module "traefik" {
  source = "git::https://github.com/traefik/traefik-demo.git//terraform/traefik/k8s?ref=v4.0.0"

  name              = "traefik"
  namespace         = "traefik"
  traefik_hub_token = var.traefik_hub_token
}
```

## Prerequisites

- A working Kubernetes cluster with `helm`, `kubernetes`, and `null` providers configured.
- A Traefik Hub token.

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name | Version |
|------|---------|
| helm | ~> 3.0 |
| kubernetes | >= 2.0 |
| null | >= 3.0 |

## Providers

| Name | Source | Version |
|------|--------|---------|
| helm | `hashicorp/helm` | `~> 3.0` |
| kubernetes | `hashicorp/kubernetes` | `>= 2.0` |
| null | `hashicorp/null` | `>= 3.0` |

## Resources

| Name | Type |
|------|------|
| `null_resource.traefik-crds` | resource |
| `kubernetes_secret_v1.traefik-hub-license` | resource |
| `kubernetes_config_map_v1.traefik-dynamic-config` | resource |
| `helm_release.traefik` | resource |
| `helm_release.dns-traefiker` | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| namespace | Namespace for the Traefik Hub deployment | `string` | n/a | yes |
| additional_volume_mounts | Additional volume mounts for the Traefik container | `list(any)` | `[]` | no |
| additional_volumes | Additional volumes to mount in the Traefik pod | `list(any)` | `[]` | no |
| cloudflare_dns 🔒 | Cloudflare DNS configuration for certificate resolver | `object({enabled = optional(bool, false), domain = optional(string, ""), api_token = optional(string, ""), extra_san_domains = optional(list(string), []))` | `{"enabled":false,"domain":"","api_token":"","extra_san_domains":[]}` | no |
| custom_arguments | Additional CLI arguments for Traefik | `list(string)` | `[]` | no |
| custom_envs | Custom environment variables | `list(object({name = string, value = string))` | `[]` | no |
| custom_image_registry | Custom image registry | `string` | `""` | no |
| custom_image_repository | Custom image repository | `string` | `""` | no |
| custom_image_tag | Custom image tag | `string` | `""` | no |
| custom_objects | Extra Kubernetes objects to deploy | `list(object({))` | `[]` | no |
| custom_plugins | Custom plugins to use for the deployment | `map(object({moduleName = string, version = string))` | `{}` | no |
| custom_ports | Custom ports configuration | `any` | `{}` | no |
| custom_providers | Custom providers to use for the deployment | `any` | `{}` | no |
| dashboard_entrypoints | Dashboard entry points | `list(string)` | `["traefik"]` | no |
| dashboard_insecure | Enable insecure dashboard access (no auth) | `bool` | `false` | no |
| dashboard_match_rule | Match rule for the Traefik dashboard router | `string` | `""` | no |
| deployment_type | Traefik deployment type | `string` | `"Deployment"` | no |
| dns_traefiker | DNS Traefiker configuration for automatic domain registration | `object({enabled = optional(bool, false), chart = optional(string, ""), unique_domain = optional(bool, false), domain = optional(string, ""), enable_airlines_subdomain = optional(bool, false), ip_override = optional(string, ""), proxied = optional(bool, false))` | `{"enabled":false}` | no |
| enable_access_logs | Enable Traefik access logs | `bool` | `true` | no |
| enable_ai_gateway | Enable Traefik Hub AI Gateway features | `bool` | `false` | no |
| enable_api_gateway | Enable Traefik Hub API Gateway features | `bool` | `false` | no |
| enable_api_management | Enable Traefik Hub API Management features | `bool` | `false` | no |
| enable_dashboard | Enable Traefik dashboard | `bool` | `true` | no |
| enable_debug | Enable Traefik debug mode (pprof) | `bool` | `false` | no |
| enable_knative_provider | Enable Knative provider | `bool` | `false` | no |
| enable_mcp_gateway | Enable MCP Gateway (Claude, etc.) | `bool` | `false` | no |
| enable_offline_mode | Enable Traefik Hub Offline mode | `bool` | `false` | no |
| enable_otlp_access_logs | Enable OTLP access logs | `bool` | `false` | no |
| enable_otlp_application_logs | Enable OTLP application logs | `bool` | `false` | no |
| enable_otlp_metrics | Enable OTLP metrics | `bool` | `false` | no |
| enable_otlp_traces | Enable OTLP traces | `bool` | `false` | no |
| enable_preview_mode | Enable Traefik Hub Preview features | `bool` | `false` | no |
| enable_prometheus | Enable Prometheus metrics | `bool` | `false` | no |
| external_traffic_policy | The external traffic policy for the Traefik service | `string` | `"Cluster"` | no |
| extra_values | Extra Helm values to merge | `any` | `{}` | no |
| file_provider_config | YAML configuration for Traefik file provider | `string` | `""` | no |
| file_provider_path | Path where the file provider config is mounted | `string` | `"/etc/traefik/dynamic"` | no |
| ingress_class_is_default | Whether this ingress class is the default | `bool` | `true` | no |
| ingress_class_name | The name of the ingress class | `string` | `"traefik"` | no |
| is_staging_letsencrypt | Use Let's Encrypt staging environment | `bool` | `false` | no |
| kubernetes_namespaces | List of namespaces to watch for Kubernetes providers (Ingress, Gateway, CRD) | `list(string)` | `[]` | no |
| log_level | Log level (DEBUG, INFO, WARN, ERROR) | `string` | `"INFO"` | no |
| multicluster_provider | Traefik Hub multicluster provider configuration | `object({enabled = optional(bool, false), pollInterval = optional(number, null), pollTimeout = optional(number, null), children = optional(any, {))` | `{"enabled":false}` | no |
| name | The name of the traefik release | `string` | `"traefik"` | no |
| nutanix_provider 🔒 | Nutanix Prism Central provider configuration for VM discovery | `object({enabled = optional(bool, false), endpoint = optional(string, ""), username = optional(string, ""), password = optional(string, ""), api_key = optional(string, ""), insecure_skip_verify = optional(bool, false), poll_interval = optional(string, "30s"), poll_timeout = optional(string, "5s"))` | `{"enabled":false}` | no |
| otlp_address | OTLP collector endpoint | `string` | `""` | no |
| otlp_service_name | Service name for telemetry | `string` | `"traefik"` | no |
| redis_password | Redis password for API Management | `string` | `"topsecretpassword"` | no |
| replica_count | Number of replicas for the Traefik Hub deployment | `number` | `1` | no |
| replica_count | Number of replicas (K8s pods) | `number` | `1` | no |
| resources | Resources for the Traefik deployment. Set to null or leave empty strings to use chart defaults. | `object({requests = object({cpu = string, memory = string), limits = object({cpu = string, memory = string))` | `None` | no |
| service_type | Traefik service type | `string` | `"LoadBalancer"` | no |
| service_annotations | Extra annotations for the Traefik service | `map(string)` | `{}` | no |
| skip_crds | Skip CRD installation (for NKP/Kommander clusters with pre-installed CRDs) | `bool` | `false` | no |
| skip_gateway_api_crds | Skip Gateway API CRD installation | `bool` | `false` | no |
| tolerations | Tolerations for the Traefik deployment | `list(object({key = string, operator = string, value = string, effect = string))` | `[]` | no |
| traefik_chart_version | Traefik Helm chart version | `string` | `"38.0.1"` | no |
| traefik_hub_preview_tag | Traefik Hub preview version tag | `string` | `""` | no |
| traefik_hub_tag | Traefik Hub version tag | `string` | `"v3.19.0"` | no |
| traefik_hub_token 🔒 | Traefik Hub license token | `string` | `""` | no |
| traefik_tag | Traefik OSS version tag | `string` | `"v3.6.6"` | no |
| use_distributed_acme | Use distributedAcme instead of acme (stores certs in K8s secrets instead of acme.json file) | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| dashboard_url | The Traefik dashboard URL |
| domain | The computed domain for Traefik |
| load_balancer_ip | The Load Balancer IP of the Traefik Service |

<!-- END_TF_DOCS -->
