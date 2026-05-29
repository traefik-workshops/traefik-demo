# compute/nutanix/subnet

Creates a Nutanix subnet (VLAN-backed) with optional external flag and DNS configuration.

## Example usage

```hcl
module "subnet" {
  source = "git::https://github.com/traefik/traefik-demo.git//terraform/compute/nutanix/subnet?ref=v4.0.0"

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
| [nutanix_subnet_v2.this](https://registry.terraform.io/providers/nutanix/nutanix/latest/docs/resources/subnet_v2) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_cluster_id"></a> [cluster\_id](#input\_cluster\_id) | UUID of the Nutanix Cluster | `string` | n/a | yes |
| <a name="input_gateway_ip"></a> [gateway\_ip](#input\_gateway\_ip) | Default gateway IP | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the subnet | `string` | n/a | yes |
| <a name="input_subnet_cidr"></a> [subnet\_cidr](#input\_subnet\_cidr) | CIDR block for the subnet | `string` | n/a | yes |
| <a name="input_vlan_id"></a> [vlan\_id](#input\_vlan\_id) | VLAN ID (Network ID) for the subnet | `number` | n/a | yes |
| <a name="input_description"></a> [description](#input\_description) | Description of the subnet | `string` | `"Managed by Terraform"` | no |
| <a name="input_dns_nameservers"></a> [dns\_nameservers](#input\_dns\_nameservers) | List of DNS nameservers | `list(string)` | `[]` | no |
| <a name="input_is_external"></a> [is\_external](#input\_is\_external) | Whether this is an external subnet | `bool` | `false` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_id"></a> [id](#output\_id) | Id. |
<!-- END_TF_DOCS -->
