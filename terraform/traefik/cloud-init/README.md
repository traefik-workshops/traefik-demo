# traefik/cloud-init

Renders a cloud-init template that installs and starts Traefik Hub on a VM, with optional Keepalived VRRP, OTLP export, performance tuning, and DNS Traefiker registration. No resources — output-only.

## Example usage

```hcl
module "traefik_cloud_init" {
  source = "git::https://github.com/traefik/traefik-demo.git//terraform/traefik/cloud-init?ref=v4.0.0"

  traefik_hub_version = "v3.16.0"
  arch                = "amd64"
}
```

## Prerequisites

- Consumer module that accepts cloud-init user data (e.g., `traefik/ec2`, `traefik/nutanix`).

## Notes

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
| <a name="input_traefik_hub_version"></a> [traefik\_hub\_version](#input\_traefik\_hub\_version) | The Traefik Hub version to download | `string` | n/a | yes |
| <a name="input_arch"></a> [arch](#input\_arch) | The architecture (amd64, arm64) | `string` | `"amd64"` | no |
| <a name="input_cli_arguments"></a> [cli\_arguments](#input\_cli\_arguments) | CLI arguments for Traefik Hub | `list(string)` | `[]` | no |
| <a name="input_dashboard_config"></a> [dashboard\_config](#input\_dashboard\_config) | Dashboard configuration | `string` | `""` | no |
| <a name="input_dns_traefiker"></a> [dns\_traefiker](#input\_dns\_traefiker) | DNS Traefiker configuration for automatic domain registration | <pre>object({<br/>    enabled                   = optional(bool, false)<br/>    version                   = optional(string, "v1.0.4")<br/>    chart                     = optional(string, "")<br/>    unique_domain             = optional(bool, false)<br/>    domain                    = optional(string, "")<br/>    enable_airlines_subdomain = optional(bool, false)<br/>    ip_override               = optional(string, "")<br/>    proxied                   = optional(bool, false)<br/>  })</pre> | <pre>{<br/>  "enabled": false<br/>}</pre> | no |
| <a name="input_enable_preview_mode"></a> [enable\_preview\_mode](#input\_enable\_preview\_mode) | Enable Traefik Hub Preview features (pulls binary from Docker image instead of GitHub releases) | `bool` | `false` | no |
| <a name="input_env_vars"></a> [env\_vars](#input\_env\_vars) | Environment variables for Traefik Hub | <pre>list(object({<br/>    name  = string<br/>    value = string<br/>  }))</pre> | `[]` | no |
| <a name="input_extra_files"></a> [extra\_files](#input\_extra\_files) | Extra files to write to the VM at cloud-init time (e.g. Nutanix provider supplementary config) | <pre>list(object({<br/>    path    = string<br/>    content = string<br/>  }))</pre> | `[]` | no |
| <a name="input_file_provider_config"></a> [file\_provider\_config](#input\_file\_provider\_config) | Dynamic configuration for the file provider | `string` | `""` | no |
| <a name="input_instance_name"></a> [instance\_name](#input\_instance\_name) | Unique name for this instance (used for metrics identity) | `string` | `"traefik-node"` | no |
| <a name="input_keepalived_priority"></a> [keepalived\_priority](#input\_keepalived\_priority) | Priority for Keepalived VRRP | `number` | `100` | no |
| <a name="input_network_interface"></a> [network\_interface](#input\_network\_interface) | Network interface for Keepalived | `string` | `"ens3"` | no |
| <a name="input_otlp_address"></a> [otlp\_address](#input\_otlp\_address) | OTLP endpoint URL (e.g. https://collector.example.com) | `string` | `""` | no |
| <a name="input_performance_tuning"></a> [performance\_tuning](#input\_performance\_tuning) | Performance tuning settings | <pre>object({<br/>    limit_nofile        = number<br/>    gomaxprocs          = number<br/>    gogc                = number<br/>    tcp_tw_reuse        = number<br/>    tcp_timestamps      = number<br/>    rmem_max            = number<br/>    wmem_max            = number<br/>    somaxconn           = number<br/>    netdev_max_backlog  = number<br/>    ip_local_port_range = string<br/>    numa_node           = number<br/>  })</pre> | <pre>{<br/>  "gogc": 100,<br/>  "gomaxprocs": 0,<br/>  "ip_local_port_range": "1024 65535",<br/>  "limit_nofile": 500000,<br/>  "netdev_max_backlog": 4096,<br/>  "numa_node": -1,<br/>  "rmem_max": 16777216,<br/>  "somaxconn": 4096,<br/>  "tcp_timestamps": 1,<br/>  "tcp_tw_reuse": 1,<br/>  "wmem_max": 16777216<br/>}</pre> | no |
| <a name="input_preview_image"></a> [preview\_image](#input\_preview\_image) | Full Docker image reference for preview mode (e.g. europe-west9-docker.pkg.dev/traefiklabs/traefik-hub/traefik-hub:latest-v3) | `string` | `""` | no |
| <a name="input_vip"></a> [vip](#input\_vip) | Virtual IP for Keepalived | `string` | `""` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_rendered"></a> [rendered](#output\_rendered) | Rendered. |
<!-- END_TF_DOCS -->
