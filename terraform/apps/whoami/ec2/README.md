# apps/whoami/ec2

Provisions one or more Traefik `whoami` instances on AWS EC2, wrapping `compute/aws/ec2` and the `whoami/cloud-init` template.

## Example usage

```hcl
module "whoami_ec2" {
  source = "git::https://github.com/traefik/terraform-demo-modules.git//terraform/apps/whoami/ec2?ref=v3.2.0"

  apps = {
    "demo" = {
      replicas = 2
      port     = 80
    }
  }
}
```

## Prerequisites

- AWS credentials with EC2/VPC permissions.

## Notes

- See PROV-01 in [../../../ISSUES.md](../../../ISSUES.md) — this module is missing `required_providers`.

<!-- BEGIN_TF_DOCS -->

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| ami_architecture | The architecture (x86_64, arm64) | `string` | `"x86_64"` | no |
| apps | Map of applications to deploy to EC2. Each app can have multiple replicas. | `any` | `{}` | no |
| common_tags | Common tags to apply to all instances | `map(string)` | `{}` | no |
| create_vpc | Create VPC if vpc_id is not provided | `bool` | `true` | no |
| instance_type | EC2 instance type for all echo servers | `string` | `"t3.micro"` | no |
| security_group_ids | List of security group IDs | `list(string)` | `[]` | no |
| subnet_ids | List of subnet IDs | `list(string)` | `[]` | no |
| vpc_id | VPC ID | `string` | `""` | no |
| whoami_version | The Whoami version to install | `string` | `"1.10.1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| instances | Map of all echo server instances with their details |

<!-- END_TF_DOCS -->
