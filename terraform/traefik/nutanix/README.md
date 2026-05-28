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
|------|---------|
| nutanix | >= 2.4.0 |

## Providers

| Name | Source | Version |
|------|--------|---------|
| nutanix | `nutanix/nutanix` | `>= 2.4.0` |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cluster_id | UUID of the Nutanix Cluster | `string` | n/a | yes |
| image_id | UUID of the Image to use | `string` | n/a | yes |
| subnet_uuid | UUID of the Subnet | `string` | n/a | yes |
| vm_name | Name of the VM | `string` | n/a | yes |
| arch | Architecture of the VM | `string` | `"amd64"` | no |
| cloudflare_dns 🔒 | Cloudflare DNS configuration for certificate resolver | `object({enabled = optional(bool, false), domain = optional(string, ""), api_token = optional(string, ""), extra_san_domains = optional(list(string), []))` | `{"enabled":false,"domain":"","api_token":"","extra_san_domains":[]}` | no |
| custom_arguments | Additional CLI arguments for Traefik | `list(string)` | `[]` | no |
| custom_envs | Custom environment variables | `list(object({name = string, value = string))` | `[]` | no |
| custom_image_registry | Custom image registry | `string` | `""` | no |
| custom_image_repository | Custom image repository | `string` | `""` | no |
| custom_image_tag | Custom image tag | `string` | `""` | no |
| custom_plugins | Custom plugins to use for the deployment | `map(object({moduleName = string, version = string))` | `{}` | no |
| custom_ports | Custom ports configuration | `map(object({port = number, protocol = optional(string, "tcp")))` | `{}` | no |
| dashboard_entrypoints | Dashboard entry points | `list(string)` | `["traefik"]` | no |
| dashboard_insecure | Enable insecure dashboard access (no auth) | `bool` | `false` | no |
| dashboard_match_rule | Match rule for the Traefik dashboard router | `string` | `""` | no |
| dns_traefiker | DNS Traefiker configuration for automatic domain registration | `object({enabled = optional(bool, false), version = optional(string, "v1.0.4"), chart = optional(string, ""), unique_domain = optional(bool, false), domain = optional(string, ""), enable_airlines_subdomain = optional(bool, false), ip_override = optional(string, ""), proxied = optional(bool, false))` | `{"enabled":false}` | no |
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
| entry_points | Entry points configuration | `map(object({address = string))` | `{"web":{"address":":80"},"websecure":{"address":":443"},"traefik":{"address":":8080"}}` | no |
| extra_files | Extra files to write to the VM at cloud-init time | `list(object({path = string, content = string))` | `[]` | no |
| file_provider_config | YAML configuration for Traefik file provider | `string` | `""` | no |
| file_provider_path | Path where the file provider config is mounted | `string` | `"/etc/traefik-hub/dynamic/"` | no |
| is_staging_letsencrypt | Use Let's Encrypt staging environment | `bool` | `false` | no |
| keepalived_priority | Priority for Keepalived VRRP (higher wins) | `number` | `100` | no |
| log_level | Log level (DEBUG, INFO, WARN, ERROR) | `string` | `"INFO"` | no |
| metrics_port | Port for metrics | `number` | `8082` | no |
| multicluster_provider | Traefik Hub multicluster provider configuration | `object({enabled = optional(bool, false), pollInterval = optional(number, null), pollTimeout = optional(number, null), children = optional(any, {))` | `{"enabled":false}` | no |
| network_interface | Network interface name for Keepalived VRRP | `string` | `"ens3"` | no |
| nutanix_provider 🔒 | Nutanix Prism Central provider configuration for VM discovery | `object({enabled = optional(bool, false), endpoint = optional(string, ""), username = optional(string, ""), password = optional(string, ""), api_key = optional(string, ""), insecure_skip_verify = optional(bool, false), poll_interval = optional(string, "30s"), poll_timeout = optional(string, "5s"), filename = optional(string, ""))` | `{"enabled":false}` | no |
| otlp_address | OTLP collector endpoint | `string` | `""` | no |
| otlp_service_name | Service name for telemetry | `string` | `"traefik"` | no |
| performance_tuning | OS-level performance tuning parameters for high-throughput workloads | `object({limit_nofile = optional(number, 500000), tcp_tw_reuse = optional(number, 1), tcp_timestamps = optional(number, 1), rmem_max = optional(number, 16777216), wmem_max = optional(number, 16777216), somaxconn = optional(number, 4096), netdev_max_backlog = optional(number, 4096), ip_local_port_range = optional(string, "1024 65535"), gomaxprocs = optional(number, 0), gogc = optional(number, 100), numa_node = optional(number, -1))` | `{}` | no |
| replica_count | Number of replicas (Nutanix VMs) | `number` | `1` | no |
| traefik_chart_version | Traefik Helm chart version | `string` | `"38.0.1"` | no |
| traefik_hub_preview_tag | Traefik Hub preview version tag | `string` | `""` | no |
| traefik_hub_tag | Traefik Hub version tag | `string` | `"v3.19.0"` | no |
| traefik_hub_token 🔒 | Traefik Hub license token | `string` | `""` | no |
| traefik_static_config | Traefik static configuration (YAML string) | `string` | `""` | no |
| traefik_tag | Traefik OSS version tag | `string` | `"v3.6.6"` | no |
| vip | Virtual IP for Keepalived | `string` | `""` | no |
| vm_disk_size_mib | Disk size in MiB | `number` | `20480` | no |
| vm_memory_mib | Memory size in MiB | `number` | `2048` | no |
| vm_num_sockets | Number of sockets | `number` | `1` | no |
| vm_num_vcpus_per_socket | Number of vCPUs per socket | `number` | `1` | no |
| vm_static_ip | Optional static IP for the VM's NIC (inside subnet CIDR). Empty = DHCP. | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| dashboard_url | The Traefik dashboard URL |
| ip_address | n/a |

<!-- END_TF_DOCS -->
