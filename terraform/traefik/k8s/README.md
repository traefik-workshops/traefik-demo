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
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | ~> 3.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 3.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_helm"></a> [helm](#provider\_helm) | ~> 3.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >= 2.0 |
| <a name="provider_null"></a> [null](#provider\_null) | >= 3.0 |

## Resources

| Name | Type |
| ---- | ---- |
| [helm_release.dns_traefiker](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.traefik](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_config_map_v1.traefik_dynamic_config](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map_v1) | resource |
| [kubernetes_secret_v1.traefik_hub_license](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) | resource |
| [null_resource.traefik_crds](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace for the Traefik Hub deployment | `string` | n/a | yes |
| <a name="input_additional_volume_mounts"></a> [additional\_volume\_mounts](#input\_additional\_volume\_mounts) | Additional volume mounts for the Traefik container | `list(any)` | `[]` | no |
| <a name="input_additional_volumes"></a> [additional\_volumes](#input\_additional\_volumes) | Additional volumes to mount in the Traefik pod | `list(any)` | `[]` | no |
| <a name="input_cloudflare_dns"></a> [cloudflare\_dns](#input\_cloudflare\_dns) | Cloudflare DNS configuration for certificate resolver | <pre>object({<br/>    enabled           = optional(bool, false)<br/>    domain            = optional(string, "")<br/>    api_token         = optional(string, "")<br/>    extra_san_domains = optional(list(string), [])<br/>  })</pre> | <pre>{<br/>  "api_token": "",<br/>  "domain": "",<br/>  "enabled": false,<br/>  "extra_san_domains": []<br/>}</pre> | no |
| <a name="input_custom_arguments"></a> [custom\_arguments](#input\_custom\_arguments) | Additional CLI arguments for Traefik | `list(string)` | `[]` | no |
| <a name="input_custom_envs"></a> [custom\_envs](#input\_custom\_envs) | Custom environment variables | <pre>list(object({<br/>    name  = string<br/>    value = string<br/>  }))</pre> | `[]` | no |
| <a name="input_custom_image_registry"></a> [custom\_image\_registry](#input\_custom\_image\_registry) | Custom image registry | `string` | `""` | no |
| <a name="input_custom_image_repository"></a> [custom\_image\_repository](#input\_custom\_image\_repository) | Custom image repository | `string` | `""` | no |
| <a name="input_custom_image_tag"></a> [custom\_image\_tag](#input\_custom\_image\_tag) | Custom image tag | `string` | `""` | no |
| <a name="input_custom_objects"></a> [custom\_objects](#input\_custom\_objects) | Extra Kubernetes objects to deploy | `list(object({}))` | `[]` | no |
| <a name="input_custom_plugins"></a> [custom\_plugins](#input\_custom\_plugins) | Custom plugins to use for the deployment | <pre>map(object({<br/>    moduleName = string<br/>    version    = string<br/>  }))</pre> | `{}` | no |
| <a name="input_custom_ports"></a> [custom\_ports](#input\_custom\_ports) | Custom ports configuration | `any` | `{}` | no |
| <a name="input_custom_providers"></a> [custom\_providers](#input\_custom\_providers) | Custom providers to use for the deployment | `any` | `{}` | no |
| <a name="input_dashboard_entrypoints"></a> [dashboard\_entrypoints](#input\_dashboard\_entrypoints) | Dashboard entry points | `list(string)` | <pre>[<br/>  "traefik"<br/>]</pre> | no |
| <a name="input_dashboard_insecure"></a> [dashboard\_insecure](#input\_dashboard\_insecure) | Enable insecure dashboard access (no auth) | `bool` | `false` | no |
| <a name="input_dashboard_match_rule"></a> [dashboard\_match\_rule](#input\_dashboard\_match\_rule) | Match rule for the Traefik dashboard router | `string` | `""` | no |
| <a name="input_deployment_type"></a> [deployment\_type](#input\_deployment\_type) | Traefik deployment type | `string` | `"Deployment"` | no |
| <a name="input_dns_traefiker"></a> [dns\_traefiker](#input\_dns\_traefiker) | DNS Traefiker configuration for automatic domain registration | <pre>object({<br/>    enabled                   = optional(bool, false)<br/>    chart                     = optional(string, "")<br/>    unique_domain             = optional(bool, false)<br/>    domain                    = optional(string, "")<br/>    enable_airlines_subdomain = optional(bool, false)<br/>    ip_override               = optional(string, "")<br/>    proxied                   = optional(bool, false)<br/>  })</pre> | <pre>{<br/>  "enabled": false<br/>}</pre> | no |
| <a name="input_enable_access_logs"></a> [enable\_access\_logs](#input\_enable\_access\_logs) | Enable Traefik access logs | `bool` | `true` | no |
| <a name="input_enable_ai_gateway"></a> [enable\_ai\_gateway](#input\_enable\_ai\_gateway) | Enable Traefik Hub AI Gateway features | `bool` | `false` | no |
| <a name="input_enable_api_gateway"></a> [enable\_api\_gateway](#input\_enable\_api\_gateway) | Enable Traefik Hub API Gateway features | `bool` | `false` | no |
| <a name="input_enable_api_management"></a> [enable\_api\_management](#input\_enable\_api\_management) | Enable Traefik Hub API Management features | `bool` | `false` | no |
| <a name="input_enable_dashboard"></a> [enable\_dashboard](#input\_enable\_dashboard) | Enable Traefik dashboard | `bool` | `true` | no |
| <a name="input_enable_debug"></a> [enable\_debug](#input\_enable\_debug) | Enable Traefik debug mode (pprof) | `bool` | `false` | no |
| <a name="input_enable_knative_provider"></a> [enable\_knative\_provider](#input\_enable\_knative\_provider) | Enable Knative provider | `bool` | `false` | no |
| <a name="input_enable_mcp_gateway"></a> [enable\_mcp\_gateway](#input\_enable\_mcp\_gateway) | Enable MCP Gateway (Claude, etc.) | `bool` | `false` | no |
| <a name="input_enable_offline_mode"></a> [enable\_offline\_mode](#input\_enable\_offline\_mode) | Enable Traefik Hub Offline mode | `bool` | `false` | no |
| <a name="input_enable_otlp_access_logs"></a> [enable\_otlp\_access\_logs](#input\_enable\_otlp\_access\_logs) | Enable OTLP access logs | `bool` | `false` | no |
| <a name="input_enable_otlp_application_logs"></a> [enable\_otlp\_application\_logs](#input\_enable\_otlp\_application\_logs) | Enable OTLP application logs | `bool` | `false` | no |
| <a name="input_enable_otlp_metrics"></a> [enable\_otlp\_metrics](#input\_enable\_otlp\_metrics) | Enable OTLP metrics | `bool` | `false` | no |
| <a name="input_enable_otlp_traces"></a> [enable\_otlp\_traces](#input\_enable\_otlp\_traces) | Enable OTLP traces | `bool` | `false` | no |
| <a name="input_enable_preview_mode"></a> [enable\_preview\_mode](#input\_enable\_preview\_mode) | Enable Traefik Hub Preview features | `bool` | `false` | no |
| <a name="input_enable_prometheus"></a> [enable\_prometheus](#input\_enable\_prometheus) | Enable Prometheus metrics | `bool` | `false` | no |
| <a name="input_external_traffic_policy"></a> [external\_traffic\_policy](#input\_external\_traffic\_policy) | The external traffic policy for the Traefik service | `string` | `"Cluster"` | no |
| <a name="input_extra_values"></a> [extra\_values](#input\_extra\_values) | Extra Helm values to merge | `any` | `{}` | no |
| <a name="input_file_provider_config"></a> [file\_provider\_config](#input\_file\_provider\_config) | YAML configuration for Traefik file provider | `string` | `""` | no |
| <a name="input_file_provider_path"></a> [file\_provider\_path](#input\_file\_provider\_path) | Path where the file provider config is mounted | `string` | `"/etc/traefik/dynamic"` | no |
| <a name="input_ingress_class_is_default"></a> [ingress\_class\_is\_default](#input\_ingress\_class\_is\_default) | Whether this ingress class is the default | `bool` | `true` | no |
| <a name="input_ingress_class_name"></a> [ingress\_class\_name](#input\_ingress\_class\_name) | The name of the ingress class | `string` | `"traefik"` | no |
| <a name="input_is_staging_letsencrypt"></a> [is\_staging\_letsencrypt](#input\_is\_staging\_letsencrypt) | Use Let's Encrypt staging environment | `bool` | `false` | no |
| <a name="input_kubeconfig"></a> [kubeconfig](#input\_kubeconfig) | Path to a kubeconfig the CRD install (local-exec kubectl) should use. Empty = ambient kubeconfig / current context. Set this when the cluster is created in the same terraform run, so kubectl has no current context yet (e.g. demos that build a k3d cluster in-config). | `string` | `""` | no |
| <a name="input_kubernetes_namespaces"></a> [kubernetes\_namespaces](#input\_kubernetes\_namespaces) | List of namespaces to watch for Kubernetes providers (Ingress, Gateway, CRD) | `list(string)` | `[]` | no |
| <a name="input_log_level"></a> [log\_level](#input\_log\_level) | Log level (DEBUG, INFO, WARN, ERROR) | `string` | `"INFO"` | no |
| <a name="input_multicluster_provider"></a> [multicluster\_provider](#input\_multicluster\_provider) | Traefik Hub multicluster provider configuration | <pre>object({<br/>    enabled      = optional(bool, false)<br/>    pollInterval = optional(number, null)<br/>    pollTimeout  = optional(number, null)<br/>    children     = optional(any, {})<br/>  })</pre> | <pre>{<br/>  "enabled": false<br/>}</pre> | no |
| <a name="input_name"></a> [name](#input\_name) | The name of the traefik release | `string` | `"traefik"` | no |
| <a name="input_nutanix_provider"></a> [nutanix\_provider](#input\_nutanix\_provider) | Nutanix Prism Central provider configuration for VM discovery | <pre>object({<br/>    enabled              = optional(bool, false)<br/>    endpoint             = optional(string, "")<br/>    username             = optional(string, "")<br/>    password             = optional(string, "")<br/>    api_key              = optional(string, "")<br/>    insecure_skip_verify = optional(bool, false)<br/>    poll_interval        = optional(string, "30s")<br/>    poll_timeout         = optional(string, "5s")<br/>  })</pre> | <pre>{<br/>  "enabled": false<br/>}</pre> | no |
| <a name="input_otlp_address"></a> [otlp\_address](#input\_otlp\_address) | OTLP collector endpoint | `string` | `""` | no |
| <a name="input_otlp_service_name"></a> [otlp\_service\_name](#input\_otlp\_service\_name) | Service name for telemetry | `string` | `"traefik"` | no |
| <a name="input_redis_password"></a> [redis\_password](#input\_redis\_password) | Redis password for API Management | `string` | `"topsecretpassword"` | no |
| <a name="input_replica_count"></a> [replica\_count](#input\_replica\_count) | Number of replicas for the Traefik Hub deployment | `number` | `1` | no |
| <a name="input_resources"></a> [resources](#input\_resources) | Resources for the Traefik deployment. Set to null or leave empty strings to use chart defaults. | <pre>object({<br/>    requests = object({<br/>      cpu    = string<br/>      memory = string<br/>    })<br/>    limits = object({<br/>      cpu    = string<br/>      memory = string<br/>    })<br/>  })</pre> | `null` | no |
| <a name="input_service_annotations"></a> [service\_annotations](#input\_service\_annotations) | Extra annotations for the Traefik service | `map(string)` | `{}` | no |
| <a name="input_service_type"></a> [service\_type](#input\_service\_type) | Traefik service type | `string` | `"LoadBalancer"` | no |
| <a name="input_skip_crds"></a> [skip\_crds](#input\_skip\_crds) | Skip CRD installation (for NKP/Kommander clusters with pre-installed CRDs) | `bool` | `false` | no |
| <a name="input_skip_gateway_api_crds"></a> [skip\_gateway\_api\_crds](#input\_skip\_gateway\_api\_crds) | Skip Gateway API CRD installation | `bool` | `false` | no |
| <a name="input_tolerations"></a> [tolerations](#input\_tolerations) | Tolerations for the Traefik deployment | <pre>list(object({<br/>    key      = string<br/>    operator = string<br/>    value    = string<br/>    effect   = string<br/>  }))</pre> | `[]` | no |
| <a name="input_traefik_chart_version"></a> [traefik\_chart\_version](#input\_traefik\_chart\_version) | Traefik Helm chart version (latest stable). Must render the partial metrics.otlp block this module sets: chart 38.x nil-pointers on .Values.metrics.otlp.resourceAttributes when that block is set without it; 40.x renders it. | `string` | `"40.2.0"` | no |
| <a name="input_traefik_hub_preview_tag"></a> [traefik\_hub\_preview\_tag](#input\_traefik\_hub\_preview\_tag) | Traefik Hub preview version tag | `string` | `""` | no |
| <a name="input_traefik_hub_tag"></a> [traefik\_hub\_tag](#input\_traefik\_hub\_tag) | Traefik Hub image tag for ghcr.io/traefik/traefik-hub (latest stable), paired with the default chart version above. | `string` | `"v3.20.2"` | no |
| <a name="input_traefik_hub_token"></a> [traefik\_hub\_token](#input\_traefik\_hub\_token) | Traefik Hub license token | `string` | `""` | no |
| <a name="input_traefik_tag"></a> [traefik\_tag](#input\_traefik\_tag) | Traefik OSS version tag | `string` | `"v3.6.6"` | no |
| <a name="input_use_distributed_acme"></a> [use\_distributed\_acme](#input\_use\_distributed\_acme) | Use distributedAcme instead of acme (stores certs in K8s secrets instead of acme.json file) | `bool` | `true` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_dashboard_url"></a> [dashboard\_url](#output\_dashboard\_url) | The Traefik dashboard URL |
| <a name="output_domain"></a> [domain](#output\_domain) | The computed domain for Traefik |
| <a name="output_load_balancer_ip"></a> [load\_balancer\_ip](#output\_load\_balancer\_ip) | The Load Balancer IP of the Traefik Service |
<!-- END_TF_DOCS -->
