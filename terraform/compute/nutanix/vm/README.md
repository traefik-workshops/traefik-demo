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
|------|---------|
| nutanix | >= 2.4.0 |

## Providers

| Name | Source | Version |
|------|--------|---------|
| nutanix | `nutanix/nutanix` | `>= 2.4.0` |

## Resources

| Name | Type |
|------|------|
| `nutanix_virtual_machine.vm` | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cluster_uuid | UUID of the Nutanix Cluster | `string` | n/a | yes |
| image_uuid | UUID of the source image | `string` | n/a | yes |
| name | Name of the VM | `string` | n/a | yes |
| subnet_uuid | UUID of the Subnet | `string` | n/a | yes |
| categories | Map of category key-value pairs to assign to the VM | `map(string)` | `{}` | no |
| cloud_init_user_data | Cloud-Init User Data (YAML string). Will be base64 encoded by the module. | `string` | `""` | no |
| disk_size_mib | Disk size in MiB. Overrides the source image disk size. | `number` | `20480` | no |
| memory_size_mib | Memory size in MiB | `number` | `2048` | no |
| num_sockets | Number of sockets | `number` | `1` | no |
| num_vcpus_per_socket | Number of vCPUs per socket | `number` | `1` | no |
| static_ip | Optional static IP to assign to the primary NIC. Must be inside the subnet's CIDR. Leave empty to let DHCP assign. | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| ip_address | n/a |
| vm_name | n/a |
| vm_uuid | n/a |

<!-- END_TF_DOCS -->
