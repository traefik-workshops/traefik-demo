# compute/nutanix/vm

Provisions a Nutanix VM from a source image, with optional cloud-init user data, static IP, and Prism Central categories.

## Example usage

```hcl
module "vm" {
  source = "git::https://github.com/traefik/traefik-demo.git//terraform/compute/nutanix/vm?ref=v4.0.0"

  name         = "demo-vm"
  cluster_uuid = var.cluster_uuid
  subnet_uuid  = var.subnet_uuid
  image_uuid   = var.image_uuid
}
```

## Prerequisites

- A reachable Nutanix Prism Central endpoint and credentials.
- A source image already uploaded to Prism Central.

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
| [nutanix_virtual_machine.vm](https://registry.terraform.io/providers/nutanix/nutanix/latest/docs/resources/virtual_machine) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_cluster_uuid"></a> [cluster\_uuid](#input\_cluster\_uuid) | UUID of the Nutanix Cluster | `string` | n/a | yes |
| <a name="input_image_uuid"></a> [image\_uuid](#input\_image\_uuid) | UUID of the source image | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the VM | `string` | n/a | yes |
| <a name="input_subnet_uuid"></a> [subnet\_uuid](#input\_subnet\_uuid) | UUID of the Subnet | `string` | n/a | yes |
| <a name="input_categories"></a> [categories](#input\_categories) | Map of category key-value pairs to assign to the VM | `map(string)` | `{}` | no |
| <a name="input_cloud_init_user_data"></a> [cloud\_init\_user\_data](#input\_cloud\_init\_user\_data) | Cloud-Init User Data (YAML string). Will be base64 encoded by the module. | `string` | `""` | no |
| <a name="input_disk_size_mib"></a> [disk\_size\_mib](#input\_disk\_size\_mib) | Disk size in MiB. Overrides the source image disk size. | `number` | `20480` | no |
| <a name="input_memory_size_mib"></a> [memory\_size\_mib](#input\_memory\_size\_mib) | Memory size in MiB | `number` | `2048` | no |
| <a name="input_num_sockets"></a> [num\_sockets](#input\_num\_sockets) | Number of sockets | `number` | `1` | no |
| <a name="input_num_vcpus_per_socket"></a> [num\_vcpus\_per\_socket](#input\_num\_vcpus\_per\_socket) | Number of vCPUs per socket | `number` | `1` | no |
| <a name="input_static_ip"></a> [static\_ip](#input\_static\_ip) | Optional static IP to assign to the primary NIC. Must be inside the subnet's CIDR. Leave empty to let DHCP assign. | `string` | `""` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_ip_address"></a> [ip\_address](#output\_ip\_address) | Ip address. |
| <a name="output_vm_name"></a> [vm\_name](#output\_vm\_name) | Vm name. |
| <a name="output_vm_uuid"></a> [vm\_uuid](#output\_vm\_uuid) | Vm uuid. |
<!-- END_TF_DOCS -->
