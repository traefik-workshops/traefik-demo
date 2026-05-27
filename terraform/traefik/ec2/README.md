# traefik/ec2

Provisions one or more Traefik Hub instances on AWS EC2, wiring in `traefik/shared` (config extraction) and `traefik/cloud-init` (boot script). Optional Elastic IP and ACME sync.

## Example usage

```hcl
module "traefik" {
  source = "git::https://github.com/traefik/terraform-demo-modules.git//terraform/traefik/ec2?ref=v3.2.0"

  traefik_hub_token = var.traefik_hub_token
  replica_count     = 1
}
```

## Prerequisites

- AWS credentials with EC2/VPC permissions.
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

## Resources

| Name | Type |
|------|------|
| `aws_eip.traefik` | resource |
| `null_resource.wait_for_traefik` | resource |
| `null_resource.wait_for_acme_primary` | resource |
| `null_resource.sync_acme_secondary` | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| ami_architecture | AMI architecture (x86_64 or arm64) | `string` | `"x86_64"` | no |
| cloudflare_dns 🔒 | Cloudflare DNS configuration for certificate resolver | `object({enabled = optional(bool, false), domain = optional(string, ""), api_token = optional(string, ""), extra_san_domains = optional(list(string), []))` | `{"enabled":false,"domain":"","api_token":"","extra_san_domains":[]}` | no |
| create_eip | Create and attach an Elastic IP to the first Traefik instance | `bool` | `false` | no |
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
| dns_traefiker | DNS Traefiker configuration for automatic domain registration | `object({enabled = optional(bool, false), chart = optional(string, ""), unique_domain = optional(bool, false), domain = optional(string, ""), enable_airlines_subdomain = optional(bool, false), ip_override = optional(string, ""), proxied = optional(bool, false))` | `{"enabled":false}` | no |
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
| extra_files | Extra files to write to the VM at cloud-init time | `list(object({path = string, content = string))` | `[]` | no |
| extra_tags | Extra tags to apply to EC2 instances | `map(string)` | `{}` | no |
| file_provider_config | YAML configuration for Traefik file provider | `string` | `""` | no |
| file_provider_path | Path where the file provider config is mounted | `string` | `"/etc/traefik-hub/dynamic"` | no |
| iam_instance_profile | IAM instance profile name to attach to EC2 instances | `string` | `""` | no |
| instance_type | EC2 instance type | `string` | `"t3.small"` | no |
| is_staging_letsencrypt | Use Let's Encrypt staging environment | `bool` | `false` | no |
| log_level | Log level (DEBUG, INFO, WARN, ERROR) | `string` | `"INFO"` | no |
| multicluster_provider | Traefik Hub multicluster provider configuration | `object({enabled = optional(bool, false), pollInterval = optional(number, null), pollTimeout = optional(number, null), children = optional(any, {))` | `{"enabled":false}` | no |
| nutanix_provider 🔒 | Nutanix Prism Central provider configuration for VM discovery | `object({enabled = optional(bool, false), endpoint = optional(string, ""), username = optional(string, ""), password = optional(string, ""), api_key = optional(string, ""), insecure_skip_verify = optional(bool, false), poll_interval = optional(string, "30s"), poll_timeout = optional(string, "5s"), filename = optional(string, ""))` | `{"enabled":false}` | no |
| otlp_address | OTLP collector endpoint | `string` | `""` | no |
| otlp_service_name | Service name for telemetry | `string` | `"traefik"` | no |
| performance_tuning | OS-level performance tuning parameters for high-throughput workloads | `object({limit_nofile = optional(number, 500000), tcp_tw_reuse = optional(number, 1), tcp_timestamps = optional(number, 1), rmem_max = optional(number, 16777216), wmem_max = optional(number, 16777216), somaxconn = optional(number, 4096), netdev_max_backlog = optional(number, 4096), ip_local_port_range = optional(string, "1024 65535"), gomaxprocs = optional(number, 0), gogc = optional(number, 100), numa_node = optional(number, -1))` | `{}` | no |
| replica_count | Number of replicas (EC2 instances) | `number` | `1` | no |
| root_block_device_size | Root block device size in GB | `number` | `30` | no |
| security_group_ids | List of security group IDs for EC2 instances | `list(string)` | `[]` | no |
| subnet_ids | List of subnet IDs for EC2 instances | `list(string)` | `[]` | no |
| sync_acme | Synchronize acme.json from the first instance to all others | `bool` | `false` | no |
| traefik_chart_version | Traefik Helm chart version | `string` | `"38.0.1"` | no |
| traefik_hub_preview_tag | Traefik Hub preview version tag | `string` | `""` | no |
| traefik_hub_tag | Traefik Hub version tag | `string` | `"v3.19.0"` | no |
| traefik_hub_token 🔒 | Traefik Hub license token | `string` | `""` | no |
| traefik_tag | Traefik OSS version tag | `string` | `"v3.6.6"` | no |
| vpc_id | VPC ID for EC2 instances | `string` | `""` | no |
| wait_for_ready | Wait for Traefik to be ready (responding on port 80) before completing | `bool` | `true` | no |
| wait_timeout | Timeout in seconds to wait for Traefik readiness | `number` | `300` | no |

## Outputs

| Name | Description |
|------|-------------|
| instances | Map of EC2 instances with their details |
| private_ips | Map of instance names to their private IP addresses |
| public_ips | Map of instance names to their public IP addresses (Elastic IPs if created, otherwise instance public IPs) |

<!-- END_TF_DOCS -->
