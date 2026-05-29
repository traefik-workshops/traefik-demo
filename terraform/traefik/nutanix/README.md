# traefik/nutanix

Provisions a Traefik Hub VM on Nutanix AHV via `compute/nutanix/vm`, wiring in `traefik/shared` (config) and `traefik/cloud-init` (boot script). Supports Keepalived VRRP for high availability.

## Example usage

```hcl
module "traefik_nutanix" {
  source = "git::https://github.com/traefik/traefik-demo.git//terraform/traefik/nutanix?ref=v4.0.0"

  vm_name           = "traefik-01"
  cluster_id        = var.cluster_uuid
  subnet_uuid       = var.subnet_uuid
  image_id          = var.image_uuid
  traefik_hub_token = var.traefik_hub_token
}
```

## Prerequisites

- A reachable Nutanix Prism Central endpoint and credentials.
- A pre-built Traefik VM image (qcow2 with cloud-init).
- A Traefik Hub token.

<!-- BEGIN_TF_DOCS -->


## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |

## Providers

No providers.

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_cluster_id"></a> [cluster\_id](#input\_cluster\_id) | UUID of the Nutanix Cluster | `string` | n/a | yes |
| <a name="input_image_id"></a> [image\_id](#input\_image\_id) | UUID of the Image to use | `string` | n/a | yes |
| <a name="input_subnet_uuid"></a> [subnet\_uuid](#input\_subnet\_uuid) | UUID of the Subnet | `string` | n/a | yes |
| <a name="input_vm_name"></a> [vm\_name](#input\_vm\_name) | Name of the VM | `string` | n/a | yes |
| <a name="input_arch"></a> [arch](#input\_arch) | Architecture of the VM | `string` | `"amd64"` | no |
| <a name="input_cloudflare_dns"></a> [cloudflare\_dns](#input\_cloudflare\_dns) | Cloudflare DNS configuration for certificate resolver | <pre>object({<br/>    enabled           = optional(bool, false)<br/>    domain            = optional(string, "")<br/>    api_token         = optional(string, "")<br/>    extra_san_domains = optional(list(string), [])<br/>  })</pre> | <pre>{<br/>  "api_token": "",<br/>  "domain": "",<br/>  "enabled": false,<br/>  "extra_san_domains": []<br/>}</pre> | no |
| <a name="input_custom_arguments"></a> [custom\_arguments](#input\_custom\_arguments) | Additional CLI arguments for Traefik | `list(string)` | `[]` | no |
| <a name="input_custom_envs"></a> [custom\_envs](#input\_custom\_envs) | Custom environment variables | <pre>list(object({<br/>    name  = string<br/>    value = string<br/>  }))</pre> | `[]` | no |
| <a name="input_custom_image_registry"></a> [custom\_image\_registry](#input\_custom\_image\_registry) | Custom image registry | `string` | `""` | no |
| <a name="input_custom_image_repository"></a> [custom\_image\_repository](#input\_custom\_image\_repository) | Custom image repository | `string` | `""` | no |
| <a name="input_custom_image_tag"></a> [custom\_image\_tag](#input\_custom\_image\_tag) | Custom image tag | `string` | `""` | no |
| <a name="input_custom_plugins"></a> [custom\_plugins](#input\_custom\_plugins) | Custom plugins to use for the deployment | <pre>map(object({<br/>    moduleName = string<br/>    version    = string<br/>  }))</pre> | `{}` | no |
| <a name="input_custom_ports"></a> [custom\_ports](#input\_custom\_ports) | Custom ports configuration | <pre>map(object({<br/>    port     = number<br/>    protocol = optional(string, "tcp")<br/>  }))</pre> | `{}` | no |
| <a name="input_dashboard_entrypoints"></a> [dashboard\_entrypoints](#input\_dashboard\_entrypoints) | Dashboard entry points | `list(string)` | <pre>[<br/>  "traefik"<br/>]</pre> | no |
| <a name="input_dashboard_insecure"></a> [dashboard\_insecure](#input\_dashboard\_insecure) | Enable insecure dashboard access (no auth) | `bool` | `false` | no |
| <a name="input_dashboard_match_rule"></a> [dashboard\_match\_rule](#input\_dashboard\_match\_rule) | Match rule for the Traefik dashboard router | `string` | `""` | no |
| <a name="input_dns_traefiker"></a> [dns\_traefiker](#input\_dns\_traefiker) | DNS Traefiker configuration for automatic domain registration | <pre>object({<br/>    enabled                   = optional(bool, false)<br/>    version                   = optional(string, "v1.0.4")<br/>    chart                     = optional(string, "")<br/>    unique_domain             = optional(bool, false)<br/>    domain                    = optional(string, "")<br/>    enable_airlines_subdomain = optional(bool, false)<br/>    ip_override               = optional(string, "")<br/>    proxied                   = optional(bool, false)<br/>  })</pre> | <pre>{<br/>  "enabled": false<br/>}</pre> | no |
| <a name="input_enable_access_logs"></a> [enable\_access\_logs](#input\_enable\_access\_logs) | Enable Traefik access logs | `bool` | `true` | no |
| <a name="input_enable_ai_gateway"></a> [enable\_ai\_gateway](#input\_enable\_ai\_gateway) | Enable Traefik Hub AI Gateway features | `bool` | `false` | no |
| <a name="input_enable_api_gateway"></a> [enable\_api\_gateway](#input\_enable\_api\_gateway) | Enable Traefik Hub API Gateway features | `bool` | `false` | no |
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
| <a name="input_entry_points"></a> [entry\_points](#input\_entry\_points) | Entry points configuration | <pre>map(object({<br/>    address = string<br/>  }))</pre> | <pre>{<br/>  "traefik": {<br/>    "address": ":8080"<br/>  },<br/>  "web": {<br/>    "address": ":80"<br/>  },<br/>  "websecure": {<br/>    "address": ":443"<br/>  }<br/>}</pre> | no |
| <a name="input_extra_files"></a> [extra\_files](#input\_extra\_files) | Extra files to write to the VM at cloud-init time | <pre>list(object({<br/>    path    = string<br/>    content = string<br/>  }))</pre> | `[]` | no |
| <a name="input_file_provider_config"></a> [file\_provider\_config](#input\_file\_provider\_config) | YAML configuration for Traefik file provider | `string` | `""` | no |
| <a name="input_file_provider_path"></a> [file\_provider\_path](#input\_file\_provider\_path) | Path where the file provider config is mounted | `string` | `"/etc/traefik-hub/dynamic/"` | no |
| <a name="input_is_staging_letsencrypt"></a> [is\_staging\_letsencrypt](#input\_is\_staging\_letsencrypt) | Use Let's Encrypt staging environment | `bool` | `false` | no |
| <a name="input_keepalived_priority"></a> [keepalived\_priority](#input\_keepalived\_priority) | Priority for Keepalived VRRP (higher wins) | `number` | `100` | no |
| <a name="input_log_level"></a> [log\_level](#input\_log\_level) | Log level (DEBUG, INFO, WARN, ERROR) | `string` | `"INFO"` | no |
| <a name="input_multicluster_provider"></a> [multicluster\_provider](#input\_multicluster\_provider) | Traefik Hub multicluster provider configuration | <pre>object({<br/>    enabled      = optional(bool, false)<br/>    pollInterval = optional(number, null)<br/>    pollTimeout  = optional(number, null)<br/>    children     = optional(any, {})<br/>  })</pre> | <pre>{<br/>  "enabled": false<br/>}</pre> | no |
| <a name="input_network_interface"></a> [network\_interface](#input\_network\_interface) | Network interface name for Keepalived VRRP | `string` | `"ens3"` | no |
| <a name="input_nutanix_provider"></a> [nutanix\_provider](#input\_nutanix\_provider) | Nutanix Prism Central provider configuration for VM discovery | <pre>object({<br/>    enabled              = optional(bool, false)<br/>    endpoint             = optional(string, "")<br/>    username             = optional(string, "")<br/>    password             = optional(string, "")<br/>    api_key              = optional(string, "")<br/>    insecure_skip_verify = optional(bool, false)<br/>    poll_interval        = optional(string, "30s")<br/>    poll_timeout         = optional(string, "5s")<br/>    filename             = optional(string, "")<br/>  })</pre> | <pre>{<br/>  "enabled": false<br/>}</pre> | no |
| <a name="input_otlp_address"></a> [otlp\_address](#input\_otlp\_address) | OTLP collector endpoint | `string` | `""` | no |
| <a name="input_otlp_service_name"></a> [otlp\_service\_name](#input\_otlp\_service\_name) | Service name for telemetry | `string` | `"traefik"` | no |
| <a name="input_performance_tuning"></a> [performance\_tuning](#input\_performance\_tuning) | OS-level performance tuning parameters for high-throughput workloads | <pre>object({<br/>    # Systemd ulimits<br/>    limit_nofile = optional(number, 500000)<br/><br/>    # Sysctl network tuning<br/>    tcp_tw_reuse        = optional(number, 1)<br/>    tcp_timestamps      = optional(number, 1)<br/>    rmem_max            = optional(number, 16777216)<br/>    wmem_max            = optional(number, 16777216)<br/>    somaxconn           = optional(number, 4096)<br/>    netdev_max_backlog  = optional(number, 4096)<br/>    ip_local_port_range = optional(string, "1024 65535")<br/><br/>    # Go runtime tuning<br/>    gomaxprocs = optional(number, 0)   # 0 = use all CPUs<br/>    gogc       = optional(number, 100) # default GC target percentage<br/>    numa_node  = optional(number, -1)  # -1 = disabled, 0+ = pin to node<br/>  })</pre> | `{}` | no |
| <a name="input_replica_count"></a> [replica\_count](#input\_replica\_count) | Number of replicas (Nutanix VMs) | `number` | `1` | no |
| <a name="input_traefik_chart_version"></a> [traefik\_chart\_version](#input\_traefik\_chart\_version) | Traefik Helm chart version | `string` | `"38.0.1"` | no |
| <a name="input_traefik_hub_preview_tag"></a> [traefik\_hub\_preview\_tag](#input\_traefik\_hub\_preview\_tag) | Traefik Hub preview version tag | `string` | `""` | no |
| <a name="input_traefik_hub_tag"></a> [traefik\_hub\_tag](#input\_traefik\_hub\_tag) | Traefik Hub version tag | `string` | `"v3.19.0"` | no |
| <a name="input_traefik_hub_token"></a> [traefik\_hub\_token](#input\_traefik\_hub\_token) | Traefik Hub license token | `string` | `""` | no |
| <a name="input_traefik_tag"></a> [traefik\_tag](#input\_traefik\_tag) | Traefik OSS version tag | `string` | `"v3.6.6"` | no |
| <a name="input_vip"></a> [vip](#input\_vip) | Virtual IP for Keepalived | `string` | `""` | no |
| <a name="input_vm_disk_size_mib"></a> [vm\_disk\_size\_mib](#input\_vm\_disk\_size\_mib) | Disk size in MiB | `number` | `20480` | no |
| <a name="input_vm_memory_mib"></a> [vm\_memory\_mib](#input\_vm\_memory\_mib) | Memory size in MiB | `number` | `2048` | no |
| <a name="input_vm_num_sockets"></a> [vm\_num\_sockets](#input\_vm\_num\_sockets) | Number of sockets | `number` | `1` | no |
| <a name="input_vm_num_vcpus_per_socket"></a> [vm\_num\_vcpus\_per\_socket](#input\_vm\_num\_vcpus\_per\_socket) | Number of vCPUs per socket | `number` | `1` | no |
| <a name="input_vm_static_ip"></a> [vm\_static\_ip](#input\_vm\_static\_ip) | Optional static IP for the VM's NIC (inside subnet CIDR). Empty = DHCP. | `string` | `""` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_dashboard_url"></a> [dashboard\_url](#output\_dashboard\_url) | The Traefik dashboard URL |
| <a name="output_ip_address"></a> [ip\_address](#output\_ip\_address) | Ip address. |
<!-- END_TF_DOCS -->
