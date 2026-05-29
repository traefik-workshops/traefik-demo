# compute/nutanix/fip

Allocates a Nutanix Floating IP and associates it with a VM NIC or a VPC private IP.

## Example usage

```hcl
module "fip" {
  source = "git::https://github.com/traefik/traefik-demo.git//terraform/compute/nutanix/fip?ref=v4.0.0"

  name                 = "whoami-fip"
  external_subnet_uuid = var.external_subnet_uuid
  type                 = "VM"
  vm_nic_uuid          = module.vm.nic_uuid
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
| [nutanix_floating_ip_v2.vm_fip](https://registry.terraform.io/providers/nutanix/nutanix/latest/docs/resources/floating_ip_v2) | resource |
| [nutanix_floating_ip_v2.vpc_fip](https://registry.terraform.io/providers/nutanix/nutanix/latest/docs/resources/floating_ip_v2) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_external_subnet_uuid"></a> [external\_subnet\_uuid](#input\_external\_subnet\_uuid) | UUID of the external subnet | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the Floating IP | `string` | n/a | yes |
| <a name="input_type"></a> [type](#input\_type) | Type of FIP association: 'VM' or 'VPC' | `string` | n/a | yes |
| <a name="input_private_ip"></a> [private\_ip](#input\_private\_ip) | Private IP to associate with (required if vm\_nic\_uuid is not set) | `string` | `""` | no |
| <a name="input_vm_nic_uuid"></a> [vm\_nic\_uuid](#input\_vm\_nic\_uuid) | UUID of the VM NIC to associate with | `string` | `""` | no |
| <a name="input_vpc_uuid"></a> [vpc\_uuid](#input\_vpc\_uuid) | UUID of the VPC (required for private\_ip association) | `string` | `""` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_id"></a> [id](#output\_id) | The ID of the Floating IP |
| <a name="output_public_ip"></a> [public\_ip](#output\_public\_ip) | The allocated Floating IP address |
<!-- END_TF_DOCS -->
