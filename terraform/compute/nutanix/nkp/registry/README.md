# compute/nutanix/nkp/registry

Provisions a self-hosted container registry VM on Nutanix for use as an NKP registry mirror.

## Example usage

```hcl
module "nkp_registry" {
  source = "git::https://github.com/traefik/traefik-demo.git//terraform/compute/nutanix/nkp/registry?ref=v4.0.0"

  cluster_name        = "demo"
  nutanix_cluster_id  = var.cluster_uuid
  subnet_uuid         = var.subnet_uuid
  registry_image_uuid = module.nkp_registry_image.id
}
```

## Prerequisites

- A reachable Nutanix Prism Central endpoint and credentials.
- An NKP registry image (see `compute/nutanix/nkp/registry_image`).

## Notes

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
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Resources

| Name | Type |
| ---- | ---- |
| [nutanix_virtual_machine.registry_vm](https://registry.terraform.io/providers/nutanix/nutanix/latest/docs/resources/virtual_machine) | resource |
| [terraform_data.registry_health_check](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the cluster to prefix the VM name | `string` | n/a | yes |
| <a name="input_nutanix_cluster_id"></a> [nutanix\_cluster\_id](#input\_nutanix\_cluster\_id) | Nutanix Cluster UUID | `string` | n/a | yes |
| <a name="input_registry_image_uuid"></a> [registry\_image\_uuid](#input\_registry\_image\_uuid) | UUID of the NKP Registry Image | `string` | n/a | yes |
| <a name="input_subnet_uuid"></a> [subnet\_uuid](#input\_subnet\_uuid) | Subnet UUID for the Registry VM | `string` | n/a | yes |
| <a name="input_docker_hub_access_token"></a> [docker\_hub\_access\_token](#input\_docker\_hub\_access\_token) | Docker Hub Access Token | `string` | `""` | no |
| <a name="input_docker_hub_username"></a> [docker\_hub\_username](#input\_docker\_hub\_username) | Docker Hub Username | `string` | `""` | no |
| <a name="input_private_ip"></a> [private\_ip](#input\_private\_ip) | Optional private IP for the registry VM | `string` | `null` | no |
| <a name="input_public_ip"></a> [public\_ip](#input\_public\_ip) | Optional public IP for the registry VM | `string` | `null` | no |
| <a name="input_ssh_password"></a> [ssh\_password](#input\_ssh\_password) | SSH password used to bootstrap the registry VM. Demo default — override for anything beyond ephemeral PoCs. | `string` | `"topsecretpassword"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_registry_ip"></a> [registry\_ip](#output\_registry\_ip) | Registry ip. |
| <a name="output_registry_url"></a> [registry\_url](#output\_registry\_url) | Registry url. |
<!-- END_TF_DOCS -->
