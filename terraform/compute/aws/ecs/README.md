# compute/aws/ecs

Provisions one or more ECS clusters and the underlying task definitions/services from a nested `clusters` map.

## Example usage

```hcl
module "ecs" {
  source = "git::https://github.com/traefik/traefik-demo.git//terraform/compute/aws/ecs?ref=v4.0.0"

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
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |

## Resources

| Name | Type |
| ---- | ---- |
| [aws_ecs_cluster.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |
| [aws_ecs_service.service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_iam_role.ecs_task_execution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.ecs_task_execution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_clusters"></a> [clusters](#input\_clusters) | Map of ECS clusters with their applications | <pre>map(object({<br/>    apps = map(object({<br/>      replicas           = optional(number, 1)<br/>      subnet_ids         = optional(list(string), [])<br/>      port               = optional(number, 80)<br/>      docker_image       = optional(string, "traefik/whoami:latest")<br/>      docker_command     = optional(string, "")<br/>      labels             = optional(map(string), {})<br/>      environment        = optional(map(string), {})<br/>      security_group_ids = optional(list(string), [])<br/>    }))<br/>  }))</pre> | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the ECS Deployment | `string` | n/a | yes |
| <a name="input_common_labels"></a> [common\_labels](#input\_common\_labels) | Common labels to apply to all resources | `map(string)` | `{}` | no |
| <a name="input_create_vpc"></a> [create\_vpc](#input\_create\_vpc) | Create VPC if vpc\_id is not provided | `bool` | `true` | no |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | List of security group IDs | `list(string)` | `[]` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | List of subnet IDs | `list(string)` | `[]` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID for ECS resources | `string` | `""` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_services"></a> [services](#output\_services) | Map of all ECS services with their details |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | VPC ID the ECS services run in (created VPC, or the provided vpc\_id). |
<!-- END_TF_DOCS -->
