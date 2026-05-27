# traefik/cloud-init

Renders a cloud-init template that installs and starts Traefik Hub on a VM, with optional Keepalived VRRP, OTLP export, performance tuning, and DNS Traefiker registration. No resources — output-only.

## Example usage

```hcl
module "traefik_cloud_init" {
  source = "git::https://github.com/traefik/terraform-demo-modules.git//terraform/traefik/cloud-init?ref=v3.2.0"

  traefik_hub_version = "v3.16.0"
  arch                = "amd64"
}
```

## Prerequisites

- Consumer module that accepts cloud-init user data (e.g., `traefik/ec2`, `traefik/nutanix`).

## Notes

- See PROV-01 in [../../ISSUES.md](../../ISSUES.md) — this module is missing `required_providers`.

<!-- BEGIN_TF_DOCS -->

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| traefik_hub_version | The Traefik Hub version to download | `string` | n/a | yes |
| arch | The architecture (amd64, arm64) | `string` | `"amd64"` | no |
| cli_arguments | CLI arguments for Traefik Hub | `list(string)` | `[]` | no |
| dashboard_config | Dashboard configuration | `string` | `""` | no |
| dns_traefiker | DNS Traefiker configuration for automatic domain registration | `object({enabled = optional(bool, false), version = optional(string, "v1.0.4"), chart = optional(string, ""), unique_domain = optional(bool, false), domain = optional(string, ""), enable_airlines_subdomain = optional(bool, false), ip_override = optional(string, ""), proxied = optional(bool, false))` | `{"enabled":false}` | no |
| enable_preview_mode | Enable Traefik Hub Preview features (pulls binary from Docker image instead of GitHub releases) | `bool` | `false` | no |
| env_vars | Environment variables for Traefik Hub | `list(object({name = string, value = string))` | `[]` | no |
| extra_files | Extra files to write to the VM at cloud-init time (e.g. Nutanix provider supplementary config) | `list(object({path = string, content = string))` | `[]` | no |
| file_provider_config | Dynamic configuration for the file provider | `string` | `""` | no |
| instance_name | Unique name for this instance (used for metrics identity) | `string` | `"traefik-node"` | no |
| keepalived_priority | Priority for Keepalived VRRP | `number` | `100` | no |
| network_interface | Network interface for Keepalived | `string` | `"ens3"` | no |
| otlp_address | OTLP endpoint URL (e.g. https://collector.example.com) | `string` | `""` | no |
| performance_tuning | Performance tuning settings | `object({limit_nofile = number, gomaxprocs = number, gogc = number, tcp_tw_reuse = number, tcp_timestamps = number, rmem_max = number, wmem_max = number, somaxconn = number, netdev_max_backlog = number, ip_local_port_range = string, numa_node = number)` | `{"limit_nofile":500000,"gomaxprocs":0,"gogc":100,"tcp_tw_reuse":1,"tcp_timestamps":1,"rmem_max":16777216,"wmem_max":16777216,"somaxconn":4096,"netdev_max_backlog":4096,"ip_local_port_range":"1024 65535","numa_node":"-1"}` | no |
| preview_image | Full Docker image reference for preview mode (e.g. europe-west9-docker.pkg.dev/traefiklabs/traefik-hub/traefik-hub:latest-v3) | `string` | `""` | no |
| vip | Virtual IP for Keepalived | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| rendered | n/a |

<!-- END_TF_DOCS -->
