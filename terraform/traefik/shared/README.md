# traefik/shared

Helm-template-extraction module that renders the upstream Traefik Helm chart and exposes the CLI args, env vars, ports, image refs, and static config as outputs. Consumed by `traefik/ec2`, `traefik/ecs`, `traefik/k8s`, and `traefik/nutanix` so they all agree on what Traefik configuration looks like.

## Example usage

Consumed internally by the other `traefik/*` modules; rarely instantiated directly. If you do:

```hcl
module "traefik_config" {
  source = "git::https://github.com/traefik/traefik-demo.git//terraform/traefik/shared?ref=v4.0.0"

  traefik_hub_token = var.traefik_hub_token
  cloudflare_dns    = var.cloudflare_dns
}
```

## Prerequisites

- A Traefik Hub token.
- Local `helm` binary if `extract_config = true` (the module shells out to `helm template`).

## Notes

<!-- BEGIN_TF_DOCS -->


## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_external"></a> [external](#requirement\_external) | ~> 2.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_external"></a> [external](#provider\_external) | ~> 2.0 |

## Resources

| Name | Type |
| ---- | ---- |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_cloudflare_dns"></a> [cloudflare\_dns](#input\_cloudflare\_dns) | Cloudflare DNS configuration for certificate resolver | <pre>object({<br/>    enabled           = optional(bool, false)<br/>    domain            = optional(string, "")<br/>    api_token         = optional(string, "")<br/>    extra_san_domains = optional(list(string), [])<br/>  })</pre> | <pre>{<br/>  "api_token": "",<br/>  "domain": "",<br/>  "enabled": false,<br/>  "extra_san_domains": []<br/>}</pre> | no |
| <a name="input_custom_arguments"></a> [custom\_arguments](#input\_custom\_arguments) | Additional CLI arguments for Traefik | `list(string)` | `[]` | no |
| <a name="input_custom_envs"></a> [custom\_envs](#input\_custom\_envs) | Custom environment variables | <pre>list(object({<br/>    name  = string<br/>    value = string<br/>  }))</pre> | `[]` | no |
| <a name="input_custom_image_registry"></a> [custom\_image\_registry](#input\_custom\_image\_registry) | Custom image registry | `string` | `""` | no |
| <a name="input_custom_image_repository"></a> [custom\_image\_repository](#input\_custom\_image\_repository) | Custom image repository | `string` | `""` | no |
| <a name="input_custom_image_tag"></a> [custom\_image\_tag](#input\_custom\_image\_tag) | Custom image tag | `string` | `""` | no |
| <a name="input_custom_plugins"></a> [custom\_plugins](#input\_custom\_plugins) | Custom plugins to use for the deployment | <pre>map(object({<br/>    moduleName = string<br/>    version    = string<br/>  }))</pre> | `{}` | no |
| <a name="input_custom_ports"></a> [custom\_ports](#input\_custom\_ports) | Custom ports configuration | `any` | `{}` | no |
| <a name="input_dashboard_entrypoints"></a> [dashboard\_entrypoints](#input\_dashboard\_entrypoints) | Entrypoints for the Traefik dashboard | `list(string)` | <pre>[<br/>  "traefik"<br/>]</pre> | no |
| <a name="input_dashboard_insecure"></a> [dashboard\_insecure](#input\_dashboard\_insecure) | Enable insecure dashboard access (no auth) | `bool` | `false` | no |
| <a name="input_dashboard_match_rule"></a> [dashboard\_match\_rule](#input\_dashboard\_match\_rule) | Match rule for the Traefik dashboard router | `string` | `""` | no |
| <a name="input_dns_traefiker"></a> [dns\_traefiker](#input\_dns\_traefiker) | DNS Traefiker configuration for automatic domain registration | <pre>object({<br/>    enabled                   = optional(bool, false)<br/>    chart                     = optional(string, "")<br/>    unique_domain             = optional(bool, false)<br/>    domain                    = optional(string, "")<br/>    enable_airlines_subdomain = optional(bool, false)<br/>    ip_override               = optional(string, "")<br/>    proxied                   = optional(bool, false)<br/>  })</pre> | <pre>{<br/>  "enabled": false<br/>}</pre> | no |
| <a name="input_enable_access_logs"></a> [enable\_access\_logs](#input\_enable\_access\_logs) | Enable Traefik access logs | `bool` | `true` | no |
| <a name="input_enable_ai_gateway"></a> [enable\_ai\_gateway](#input\_enable\_ai\_gateway) | Enable Traefik Hub AI Gateway features | `bool` | `false` | no |
| <a name="input_enable_api_gateway"></a> [enable\_api\_gateway](#input\_enable\_api\_gateway) | Enable Traefik Hub API Gateway features | `bool` | `false` | no |
| <a name="input_enable_api_management"></a> [enable\_api\_management](#input\_enable\_api\_management) | Enable Traefik Hub API Management features (K8s only) | `bool` | `false` | no |
| <a name="input_enable_dashboard"></a> [enable\_dashboard](#input\_enable\_dashboard) | Enable Traefik dashboard | `bool` | `true` | no |
| <a name="input_enable_debug"></a> [enable\_debug](#input\_enable\_debug) | Enable Traefik debug mode (pprof) | `bool` | `false` | no |
| <a name="input_enable_mcp_gateway"></a> [enable\_mcp\_gateway](#input\_enable\_mcp\_gateway) | Enable MCP Gateway (Claude, etc.) | `bool` | `false` | no |
| <a name="input_enable_offline_mode"></a> [enable\_offline\_mode](#input\_enable\_offline\_mode) | Enable Traefik Hub Offline mode | `bool` | `false` | no |
| <a name="input_enable_otlp_access_logs"></a> [enable\_otlp\_access\_logs](#input\_enable\_otlp\_access\_logs) | Enable OTLP access logs | `bool` | `false` | no |
| <a name="input_enable_otlp_application_logs"></a> [enable\_otlp\_application\_logs](#input\_enable\_otlp\_application\_logs) | Enable OTLP application logs | `bool` | `false` | no |
| <a name="input_enable_otlp_metrics"></a> [enable\_otlp\_metrics](#input\_enable\_otlp\_metrics) | Enable OTLP metrics | `bool` | `false` | no |
| <a name="input_enable_otlp_traces"></a> [enable\_otlp\_traces](#input\_enable\_otlp\_traces) | Enable OTLP traces | `bool` | `false` | no |
| <a name="input_enable_preview_mode"></a> [enable\_preview\_mode](#input\_enable\_preview\_mode) | Enable Traefik Hub Preview features | `bool` | `false` | no |
| <a name="input_enable_prometheus"></a> [enable\_prometheus](#input\_enable\_prometheus) | Enable Prometheus metrics | `bool` | `false` | no |
| <a name="input_entry_points"></a> [entry\_points](#input\_entry\_points) | Entry points configuration | <pre>map(object({<br/>    address  = string<br/>    port     = optional(number)<br/>    protocol = optional(string, "TCP")<br/>  }))</pre> | <pre>{<br/>  "traefik": {<br/>    "address": ":8080",<br/>    "port": 8080<br/>  },<br/>  "web": {<br/>    "address": ":80",<br/>    "port": 80<br/>  },<br/>  "websecure": {<br/>    "address": ":443",<br/>    "port": 443<br/>  }<br/>}</pre> | no |
| <a name="input_extract_config"></a> [extract\_config](#input\_extract\_config) | Whether to run helm template extraction (for EC2/ECS/Nutanix) | `bool` | `false` | no |
| <a name="input_file_provider_config"></a> [file\_provider\_config](#input\_file\_provider\_config) | YAML content for Traefik file provider dynamic configuration | `string` | `""` | no |
| <a name="input_file_provider_path"></a> [file\_provider\_path](#input\_file\_provider\_path) | Path where the file provider config is mounted (platform-specific) | `string` | `"/file-provider"` | no |
| <a name="input_is_staging_letsencrypt"></a> [is\_staging\_letsencrypt](#input\_is\_staging\_letsencrypt) | Use Let's Encrypt staging environment | `bool` | `false` | no |
| <a name="input_log_level"></a> [log\_level](#input\_log\_level) | Log level (DEBUG, INFO, WARN, ERROR) | `string` | `"INFO"` | no |
| <a name="input_multicluster_provider"></a> [multicluster\_provider](#input\_multicluster\_provider) | Traefik Hub multicluster provider configuration | <pre>object({<br/>    enabled      = optional(bool, false)<br/>    pollInterval = optional(number, null)<br/>    pollTimeout  = optional(number, null)<br/>    children     = optional(any, {})<br/>  })</pre> | <pre>{<br/>  "enabled": false<br/>}</pre> | no |
| <a name="input_nutanix_provider"></a> [nutanix\_provider](#input\_nutanix\_provider) | Nutanix Prism Central provider configuration for VM discovery | <pre>object({<br/>    enabled              = optional(bool, false)<br/>    endpoint             = optional(string, "")<br/>    username             = optional(string, "")<br/>    password             = optional(string, "")<br/>    api_key              = optional(string, "")<br/>    insecure_skip_verify = optional(bool, false)<br/>    poll_interval        = optional(string, "30s")<br/>    poll_timeout         = optional(string, "5s")<br/>    filename             = optional(string, "")<br/>  })</pre> | <pre>{<br/>  "enabled": false<br/>}</pre> | no |
| <a name="input_otlp_address"></a> [otlp\_address](#input\_otlp\_address) | OTLP collector endpoint | `string` | `""` | no |
| <a name="input_otlp_service_name"></a> [otlp\_service\_name](#input\_otlp\_service\_name) | Service name for telemetry | `string` | `"traefik"` | no |
| <a name="input_replica_count"></a> [replica\_count](#input\_replica\_count) | Number of replicas (VMs, EC2 instances, ECS tasks, K8s pods) | `number` | `1` | no |
| <a name="input_traefik_chart_version"></a> [traefik\_chart\_version](#input\_traefik\_chart\_version) | Traefik Helm chart version | `string` | `"38.0.1"` | no |
| <a name="input_traefik_hub_preview_tag"></a> [traefik\_hub\_preview\_tag](#input\_traefik\_hub\_preview\_tag) | Traefik Hub preview version tag | `string` | `""` | no |
| <a name="input_traefik_hub_tag"></a> [traefik\_hub\_tag](#input\_traefik\_hub\_tag) | Traefik Hub version tag | `string` | `"v3.19.0"` | no |
| <a name="input_traefik_hub_token"></a> [traefik\_hub\_token](#input\_traefik\_hub\_token) | Traefik Hub license token | `string` | `""` | no |
| <a name="input_traefik_tag"></a> [traefik\_tag](#input\_traefik\_tag) | Traefik OSS version tag | `string` | `"v3.6.6"` | no |
| <a name="input_use_distributed_acme"></a> [use\_distributed\_acme](#input\_use\_distributed\_acme) | Use distributedAcme instead of acme (stores certs in K8s secrets instead of acme.json file) | `bool` | `false` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_cli_arguments"></a> [cli\_arguments](#output\_cli\_arguments) | Additional CLI arguments (from Helm values additionalArguments) |
| <a name="output_cloudflare_dns"></a> [cloudflare\_dns](#output\_cloudflare\_dns) | Cloudflare DNS configuration |
| <a name="output_computed_dashboard_match_rule"></a> [computed\_dashboard\_match\_rule](#output\_computed\_dashboard\_match\_rule) | Computed dashboard match rule |
| <a name="output_computed_dns_domain"></a> [computed\_dns\_domain](#output\_computed\_dns\_domain) | Computed DNS domain (from dns\_traefiker or cloudflare\_dns) |
| <a name="output_custom_plugins"></a> [custom\_plugins](#output\_custom\_plugins) | Custom plugins. |
| <a name="output_dashboard_entrypoints"></a> [dashboard\_entrypoints](#output\_dashboard\_entrypoints) | Dashboard entrypoints |
| <a name="output_dashboard_match_rule"></a> [dashboard\_match\_rule](#output\_dashboard\_match\_rule) | Dashboard match rule |
| <a name="output_enable_ai_gateway"></a> [enable\_ai\_gateway](#output\_enable\_ai\_gateway) | Enable ai gateway. |
| <a name="output_enable_api_gateway"></a> [enable\_api\_gateway](#output\_enable\_api\_gateway) | Enable api gateway. |
| <a name="output_enable_api_management"></a> [enable\_api\_management](#output\_enable\_api\_management) | Enable api management. |
| <a name="output_enable_mcp_gateway"></a> [enable\_mcp\_gateway](#output\_enable\_mcp\_gateway) | Enable mcp gateway. |
| <a name="output_enable_offline_mode"></a> [enable\_offline\_mode](#output\_enable\_offline\_mode) | Enable offline mode. |
| <a name="output_enable_otlp_access_logs"></a> [enable\_otlp\_access\_logs](#output\_enable\_otlp\_access\_logs) | Enable otlp access logs. |
| <a name="output_enable_otlp_application_logs"></a> [enable\_otlp\_application\_logs](#output\_enable\_otlp\_application\_logs) | Enable otlp application logs. |
| <a name="output_enable_otlp_metrics"></a> [enable\_otlp\_metrics](#output\_enable\_otlp\_metrics) | Enable otlp metrics. |
| <a name="output_enable_otlp_traces"></a> [enable\_otlp\_traces](#output\_enable\_otlp\_traces) | Enable otlp traces. |
| <a name="output_enable_preview_mode"></a> [enable\_preview\_mode](#output\_enable\_preview\_mode) | Enable preview mode. |
| <a name="output_enable_prometheus"></a> [enable\_prometheus](#output\_enable\_prometheus) | Enable prometheus. |
| <a name="output_entry_points"></a> [entry\_points](#output\_entry\_points) | Entry points configuration |
| <a name="output_env_vars_list"></a> [env\_vars\_list](#output\_env\_vars\_list) | Environment variables as list (from Helm values env) |
| <a name="output_extracted_cli_args"></a> [extracted\_cli\_args](#output\_extracted\_cli\_args) | CLI arguments extracted from rendered Helm chart |
| <a name="output_extracted_cli_args_cloud"></a> [extracted\_cli\_args\_cloud](#output\_extracted\_cli\_args\_cloud) | CLI arguments extraction filtered for cloud/VM environments (excludes Kubernetes providers) |
| <a name="output_extracted_env_vars"></a> [extracted\_env\_vars](#output\_extracted\_env\_vars) | Environment variables extracted from rendered Helm chart (as JSON string) |
| <a name="output_extracted_image"></a> [extracted\_image](#output\_extracted\_image) | Full image reference extracted from rendered Helm chart |
| <a name="output_extracted_static_config"></a> [extracted\_static\_config](#output\_extracted\_static\_config) | Static configuration YAML extracted from rendered Helm chart |
| <a name="output_extracted_volume_mounts"></a> [extracted\_volume\_mounts](#output\_extracted\_volume\_mounts) | Volume mounts extracted from rendered Helm chart (as JSON string) |
| <a name="output_extracted_volumes"></a> [extracted\_volumes](#output\_extracted\_volumes) | Volumes extracted from rendered Helm chart (as JSON string) |
| <a name="output_helm_values"></a> [helm\_values](#output\_helm\_values) | Helm values as a map (for K8s helm\_release) |
| <a name="output_helm_values_yaml"></a> [helm\_values\_yaml](#output\_helm\_values\_yaml) | Helm values as YAML string |
| <a name="output_image_config"></a> [image\_config](#output\_image\_config) | Image configuration object |
| <a name="output_image_full"></a> [image\_full](#output\_image\_full) | Computed full image reference |
| <a name="output_image_tag"></a> [image\_tag](#output\_image\_tag) | Computed image tag |
| <a name="output_letsencrypt_server"></a> [letsencrypt\_server](#output\_letsencrypt\_server) | Let's Encrypt ACME server URL |
| <a name="output_log_level"></a> [log\_level](#output\_log\_level) | Log level |
| <a name="output_otlp_endpoint"></a> [otlp\_endpoint](#output\_otlp\_endpoint) | OTLP endpoint URL |
| <a name="output_ports"></a> [ports](#output\_ports) | Ports configuration (from Helm values ports) |
| <a name="output_ports_list"></a> [ports\_list](#output\_ports\_list) | Flat list of port numbers for Docker/VM port mappings |
| <a name="output_replica_count"></a> [replica\_count](#output\_replica\_count) | Number of replicas |
| <a name="output_traefik_hub_tag"></a> [traefik\_hub\_tag](#output\_traefik\_hub\_tag) | Traefik Hub version tag |
| <a name="output_traefik_hub_token"></a> [traefik\_hub\_token](#output\_traefik\_hub\_token) | Traefik Hub license token |
<!-- END_TF_DOCS -->
