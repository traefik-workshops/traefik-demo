# compute/nutanix/vpc

Creates a Nutanix VPC and a map of overlay subnets, with configurable DNS and externally routable prefixes.

## Example usage

```hcl
module "vpc" {
  source = "git::https://github.com/traefik/traefik-demo.git//terraform/compute/nutanix/vpc?ref=v4.0.0"

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
| [nutanix_static_routes.external_reroute](https://registry.terraform.io/providers/nutanix/nutanix/latest/docs/resources/static_routes) | resource |
| [nutanix_subnet_v2.subnets](https://registry.terraform.io/providers/nutanix/nutanix/latest/docs/resources/subnet_v2) | resource |
| [nutanix_vpc_v2.vpc](https://registry.terraform.io/providers/nutanix/nutanix/latest/docs/resources/vpc_v2) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_external_subnet_uuid"></a> [external\_subnet\_uuid](#input\_external\_subnet\_uuid) | UUID of the external subnet to connect to | `string` | n/a | yes |
| <a name="input_vpc_name"></a> [vpc\_name](#input\_vpc\_name) | Name of the VPC | `string` | n/a | yes |
| <a name="input_dns_servers"></a> [dns\_servers](#input\_dns\_servers) | List of DNS Servers | `list(string)` | <pre>[<br/>  "10.8.1.10",<br/>  "10.42.196.10"<br/>]</pre> | no |
| <a name="input_externally_routable_prefixes"></a> [externally\_routable\_prefixes](#input\_externally\_routable\_prefixes) | List of externally routable prefixes | `list(string)` | `[]` | no |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | Map of subnets to create. Key is the subnet name. | <pre>map(object({<br/>    cidr          = string<br/>    prefix_length = optional(number)<br/>    subnet_type   = optional(string)<br/>    extra_ip      = optional(string)<br/>  }))</pre> | `{}` | no |
| <a name="input_vpc_type"></a> [vpc\_type](#input\_vpc\_type) | Type of VPC (REGULAR or TRANSIT) | `string` | `"REGULAR"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_subnet_uuids"></a> [subnet\_uuids](#output\_subnet\_uuids) | Subnet uuids. |
| <a name="output_vpc_uuid"></a> [vpc\_uuid](#output\_vpc\_uuid) | Vpc uuid. |
<!-- END_TF_DOCS -->
