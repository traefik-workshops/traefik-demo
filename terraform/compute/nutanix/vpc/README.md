# compute/nutanix/vpc

Creates a Nutanix VPC and a map of overlay subnets, with configurable DNS and externally routable prefixes.

## Example usage

```hcl
module "vpc" {
  source = "git::https://github.com/traefik/traefik-demo.git//terraform/compute/nutanix/vpc?ref=v3.2.0"

  vpc_name             = "demo"
  external_subnet_uuid = var.external_subnet_uuid
  subnets = {
    "default" = { cidr = "10.0.0.0/24" }
  }
}
```

## Prerequisites

- A reachable Nutanix Prism Central endpoint and credentials.
- An existing external subnet to connect to.

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
| `nutanix_vpc_v2.vpc` | resource |
| `nutanix_subnet_v2.subnets` | resource |
| `nutanix_static_routes.external_reroute` | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| external_subnet_uuid | UUID of the external subnet to connect to | `string` | n/a | yes |
| vpc_name | Name of the VPC | `string` | n/a | yes |
| dns_servers | List of DNS Servers | `list(string)` | `["10.8.1.10","10.42.196.10"]` | no |
| externally_routable_prefixes | List of externally routable prefixes | `list(string)` | `[]` | no |
| subnets | Map of subnets to create. Key is the subnet name. | `map(object({cidr = string, prefix_length = optional(number), subnet_type = optional(string), extra_ip = optional(string)))` | `{}` | no |
| vpc_type | Type of VPC (REGULAR or TRANSIT) | `string` | `"REGULAR"` | no |

## Outputs

| Name | Description |
|------|-------------|
| subnet_uuids | n/a |
| vpc_uuid | n/a |

<!-- END_TF_DOCS -->
