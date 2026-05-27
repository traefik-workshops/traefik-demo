# apps/whoami/ecs

Provisions Traefik `whoami` services across one or more ECS clusters, wrapping `compute/aws/ecs`.

## Example usage

```hcl
module "whoami_ecs" {
  source = "git::https://github.com/traefik/terraform-demo-modules.git//terraform/apps/whoami/ecs?ref=v3.2.0"

  name = "whoami"
  clusters = {
    "demo" = {
      apps               = { "whoami-1" = { port = 80 } }
      subnet_ids         = []
      security_group_ids = []
    }
  }
}
```

## Prerequisites

- AWS credentials with ECS/VPC permissions.

## Notes

- See PROV-01 in [../../../ISSUES.md](../../../ISSUES.md) — this module is missing `required_providers`.

<!-- BEGIN_TF_DOCS -->

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name of the ECS Deployment | `string` | n/a | yes |
| clusters | Map of ECS clusters with their echo applications. | `any` | `{}` | no |
| common_labels | Common labels to apply to all resources | `map(string)` | `{}` | no |
| create_vpc | Create VPC if vpc_id is not provided | `bool` | `true` | no |
| security_group_ids | List of security group IDs for ECS resources | `list(string)` | `[]` | no |
| subnet_ids | List of subnet IDs for ECS resources | `list(string)` | `[]` | no |
| vpc_id | VPC ID for ECS resources | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| services | Map of ECS services |

<!-- END_TF_DOCS -->
