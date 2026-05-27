# compute/aws/vpc

Provisions an AWS VPC with public and private subnets (via the community `terraform-aws-modules/vpc` module) and a demo security group.

## Example usage

```hcl
module "vpc" {
  source = "git::https://github.com/traefik/terraform-demo-modules.git//terraform/compute/aws/vpc?ref=v3.2.0"

  name = "demo"
}
```

## Prerequisites

- AWS credentials with VPC/EC2 permissions.

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name | Version |
|------|---------|
| aws | ~> 5.0 |

## Providers

| Name | Source | Version |
|------|--------|---------|
| aws | `hashicorp/aws` | `~> 5.0` |

## Resources

| Name | Type |
|------|------|
| `aws_security_group.demo_sg` | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | VPC name. | `string` | n/a | yes |
| cidr | VPC CIDR. | `string` | `"10.0.0.0/16"` | no |
| enable_nat_gateway | Enable NAT Gateway. | `bool` | `true` | no |
| private_subnets | Private subnets. | `list(string)` | `["10.0.1.0/24","10.0.2.0/24","10.0.3.0/24"]` | no |
| public_subnets | Public subnets. | `list(string)` | `["10.0.4.0/24","10.0.5.0/24","10.0.6.0/24"]` | no |

## Outputs

| Name | Description |
|------|-------------|
| private_route_table_ids | Private route table IDs |
| private_subnet_ids | Private subnets IDs |
| public_route_table_ids | Public route table IDs |
| public_subnet_ids | Public subnets IDs |
| security_group_ids | Security group ID |
| vpc_id | VPC ID |

<!-- END_TF_DOCS -->
