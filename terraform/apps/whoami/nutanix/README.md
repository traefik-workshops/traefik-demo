# apps/whoami/nutanix

Provisions a Traefik `whoami` VM on Nutanix AHV via `compute/nutanix/vm`, with cloud-init and Prism Central category-based service discovery.

## Example usage

```hcl
module "whoami_nutanix" {
  source = "git::https://github.com/traefik/traefik-demo.git//terraform/apps/whoami/nutanix?ref=v3.2.0"

  vm_name     = "whoami-01"
  cluster_id  = var.nutanix_cluster_uuid
  subnet_uuid = var.subnet_uuid
  image_id    = module.whoami_image.id
}
```

## Prerequisites

- A reachable Nutanix Prism Central endpoint and credentials.
- A pre-built whoami image (see `apps/whoami/nutanix/image_builder`).

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
| load_balancer_strategy | Load balancer strategy for Nutanix Prism Central discovery (TraefikLoadBalancerStrategy category) | `string` | `""` | no |
| service_name | Service name for Nutanix Prism Central discovery (TraefikServiceName category) | `string` | `"whoami"` | no |
| service_port | Service port for Nutanix Prism Central discovery (TraefikServicePort category) | `number` | `8080` | no |
| vm_memory_mib | Memory size in MiB | `number` | `1024` | no |
| vm_num_sockets | Number of sockets | `number` | `1` | no |
| vm_num_vcpus_per_socket | Number of vCPUs per socket | `number` | `1` | no |
| whoami_version | The Whoami version to install | `string` | `"v1.10.1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| ip_address | n/a |

<!-- END_TF_DOCS -->
