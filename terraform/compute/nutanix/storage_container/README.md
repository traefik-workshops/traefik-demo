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
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_nutanix"></a> [nutanix](#requirement\_nutanix) | >= 2.4.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_nutanix"></a> [nutanix](#provider\_nutanix) | >= 2.4.0 |

## Resources

| Name | Type |
| ---- | ---- |
| [nutanix_storage_containers_v2.container](https://registry.terraform.io/providers/nutanix/nutanix/latest/docs/resources/storage_containers_v2) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_cluster_ext_id"></a> [cluster\_ext\_id](#input\_cluster\_ext\_id) | The external ID of the Nutanix cluster | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the storage container | `string` | n/a | yes |
| <a name="input_compression_enabled"></a> [compression\_enabled](#input\_compression\_enabled) | Enable inline compression | `bool` | `true` | no |
| <a name="input_erasure_coding_enabled"></a> [erasure\_coding\_enabled](#input\_erasure\_coding\_enabled) | Enable erasure coding for storage efficiency | `bool` | `false` | no |
| <a name="input_replication_factor"></a> [replication\_factor](#input\_replication\_factor) | Replication factor for data redundancy (2 or 3) | `number` | `2` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_ext_id"></a> [ext\_id](#output\_ext\_id) | External ID of the storage container |
| <a name="output_id"></a> [id](#output\_id) | UUID of the storage container |
| <a name="output_name"></a> [name](#output\_name) | Name of the storage container |
<!-- END_TF_DOCS -->
