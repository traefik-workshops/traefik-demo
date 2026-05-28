# compute/nutanix/subnet

Creates a Nutanix subnet (VLAN-backed) with optional external flag and DNS configuration.

## Example usage

```hcl
module "subnet" {
  source = "git::https://github.com/traefik/traefik-demo.git//terraform/compute/nutanix/subnet?ref=v3.2.0"

  name        = "demo-subnet"
  cluster_id  = var.cluster_uuid
  vlan_id     = 100
  subnet_cidr = "10.0.0.0/24"
  gateway_ip  = "10.0.0.1"
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
| `nutanix_subnet_v2.this` | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cluster_id | UUID of the Nutanix Cluster | `string` | n/a | yes |
| gateway_ip | Default gateway IP | `string` | n/a | yes |
| name | Name of the subnet | `string` | n/a | yes |
| subnet_cidr | CIDR block for the subnet | `string` | n/a | yes |
| vlan_id | VLAN ID (Network ID) for the subnet | `number` | n/a | yes |
| description | Description of the subnet | `string` | `"Managed by Terraform"` | no |
| dns_nameservers | List of DNS nameservers | `list(string)` | `[]` | no |
| is_external | Whether this is an external subnet | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | n/a |

<!-- END_TF_DOCS -->
