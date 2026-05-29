# apps/whoami/ec2

Provisions one or more Traefik `whoami` instances on AWS EC2, wrapping `compute/aws/ec2` and the `whoami/cloud-init` template.

## Example usage

```hcl
module "whoami_ec2" {
  source = "git::https://github.com/traefik/traefik-demo.git//terraform/apps/whoami/ec2?ref=v4.0.0"

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

<!-- BEGIN_TF_DOCS -->


## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |

## Providers

No providers.

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_ami_architecture"></a> [ami\_architecture](#input\_ami\_architecture) | The architecture (x86\_64, arm64) | `string` | `"x86_64"` | no |
| <a name="input_apps"></a> [apps](#input\_apps) | Map of applications to deploy to EC2. Each app can have multiple replicas. | `any` | `{}` | no |
| <a name="input_common_tags"></a> [common\_tags](#input\_common\_tags) | Common tags to apply to all instances | `map(string)` | `{}` | no |
| <a name="input_create_vpc"></a> [create\_vpc](#input\_create\_vpc) | Create VPC if vpc\_id is not provided | `bool` | `true` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | EC2 instance type for all echo servers | `string` | `"t3.micro"` | no |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | List of security group IDs | `list(string)` | `[]` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | List of subnet IDs | `list(string)` | `[]` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID | `string` | `""` | no |
| <a name="input_whoami_version"></a> [whoami\_version](#input\_whoami\_version) | The Whoami version to install | `string` | `"1.10.1"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_instances"></a> [instances](#output\_instances) | Map of all echo server instances with their details |
<!-- END_TF_DOCS -->
