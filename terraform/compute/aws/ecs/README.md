# compute/aws/ecs

Provisions one or more ECS clusters and the underlying task definitions/services from a nested `clusters` map.

## Example usage

```hcl
module "ecs" {
  source = "git::https://github.com/traefik/terraform-demo-modules.git//terraform/compute/aws/ecs?ref=v3.2.0"

  name = "demo"
  clusters = {
    "demo" = {
      apps = {
        "whoami" = { docker_image = "traefik/whoami:latest", port = 80 }
      }
    }
  }
}
```

## Prerequisites

- AWS credentials with ECS/VPC permissions.

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
| `aws_ecs_cluster.cluster` | resource |
| `aws_iam_role.ecs_task_execution` | resource |
| `aws_iam_role_policy_attachment.ecs_task_execution` | resource |
| `aws_ecs_task_definition.service` | resource |
| `aws_ecs_service.service` | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| clusters | Map of ECS clusters with their applications | `map(object({apps = map(object({replicas = optional(number, 1), subnet_ids = optional(list(string), []), port = optional(number, 80), docker_image = optional(string, "traefik/whoami:latest"), docker_command = optional(string, ""), labels = optional(map(string), {), environment = optional(map(string), {), security_group_ids = optional(list(string), [])))))` | n/a | yes |
| name | Name of the ECS Deployment | `string` | n/a | yes |
| common_labels | Common labels to apply to all resources | `map(string)` | `{}` | no |
| create_vpc | Create VPC if vpc_id is not provided | `bool` | `true` | no |
| security_group_ids | List of security group IDs | `list(string)` | `[]` | no |
| subnet_ids | List of subnet IDs | `list(string)` | `[]` | no |
| vpc_id | VPC ID for ECS resources | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| services | Map of all ECS services with their details |

<!-- END_TF_DOCS -->
