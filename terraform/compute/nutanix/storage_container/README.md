# compute/nutanix/storage_container

Creates a Nutanix storage container with configurable replication factor, compression, and erasure coding.

## Example usage

```hcl
module "storage_container" {
  source = "git::https://github.com/traefik/traefik-demo.git//terraform/compute/nutanix/storage_container?ref=v4.0.0"

  name           = "demo-sc"
  cluster_ext_id = var.cluster_ext_id
}
```

## Prerequisites

- A reachable Nutanix Prism Central endpoint and credentials.

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name | Version |
|------|---------|
| nutanix | >= 2.4.0 |

## Providers

| Name | Source | Version |
|------|--------|---------|
| nutanix | `nutanix/nutanix` | `>= 2.4.0` |

## Resources

| Name | Type |
|------|------|
| `nutanix_storage_containers_v2.container` | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cluster_ext_id | The external ID of the Nutanix cluster | `string` | n/a | yes |
| name | Name of the storage container | `string` | n/a | yes |
| compression_enabled | Enable inline compression | `bool` | `true` | no |
| erasure_coding_enabled | Enable erasure coding for storage efficiency | `bool` | `false` | no |
| replication_factor | Replication factor for data redundancy (2 or 3) | `number` | `2` | no |

## Outputs

| Name | Description |
|------|-------------|
| ext_id | External ID of the storage container |
| id | UUID of the storage container |
| name | Name of the storage container |

<!-- END_TF_DOCS -->
