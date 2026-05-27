# compute/nutanix/fip

Allocates a Nutanix Floating IP and associates it with a VM NIC or a VPC private IP.

## Example usage

```hcl
module "fip" {
  source = "git::https://github.com/traefik/terraform-demo-modules.git//terraform/compute/nutanix/fip?ref=v3.2.0"

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
|------|---------|
| nutanix | >= 2.4.0 |

## Providers

| Name | Source | Version |
|------|--------|---------|
| nutanix | `nutanix/nutanix` | `>= 2.4.0` |

## Resources

| Name | Type |
|------|------|
| `nutanix_floating_ip_v2.vm_fip` | resource |
| `nutanix_floating_ip_v2.vpc_fip` | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| external_subnet_uuid | UUID of the external subnet | `string` | n/a | yes |
| name | Name of the Floating IP | `string` | n/a | yes |
| type | Type of FIP association: 'VM' or 'VPC' | `string` | n/a | yes |
| private_ip | Private IP to associate with (required if vm_nic_uuid is not set) | `string` | `""` | no |
| vm_nic_uuid | UUID of the VM NIC to associate with | `string` | `""` | no |
| vpc_uuid | UUID of the VPC (required for private_ip association) | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the Floating IP |
| public_ip | The allocated Floating IP address |

<!-- END_TF_DOCS -->
