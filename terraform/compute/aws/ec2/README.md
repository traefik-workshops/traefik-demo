# compute/aws/ec2

Provisions a fleet of EC2 instances from an `apps` map (each app supports replicas, Docker-based user-data, optional VPC creation).

## Example usage

```hcl
module "ec2" {
  source = "git::https://github.com/traefik/traefik-demo.git//terraform/compute/aws/ec2?ref=v3.2.0"

  apps = {
    "whoami" = {
      replicas     = 2
      port         = 80
      docker_image = "traefik/whoami:latest"
    }
  }
}
```

## Prerequisites

- AWS credentials with EC2/VPC permissions.
- See [../../../AGENTS.md](../../../AGENTS.md) for repo-wide conventions.

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
| `terraform_data.replacement_trigger` | resource |
| `aws_instance.ec2` | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| apps | Map of applications to deploy with multiple replicas | `map(object({replicas = optional(number, 1), subnet_ids = optional(list(string), []), port = optional(number, 80), docker_image = optional(string, "traefik/whoami:latest"), docker_options = optional(string, ""), container_arguments = optional(string, ""), tags = optional(map(string), {)))` | n/a | yes |
| ami_architecture | AMI architecture (x86_64 or arm64) | `string` | `"x86_64"` | no |
| associate_public_ip_address | Associate a public IP address with an instance in a VPC | `bool` | `true` | no |
| common_tags | Common tags to apply to all instances | `map(string)` | `{}` | no |
| create_vpc | Create VPC if vpc_id is not provided | `bool` | `true` | no |
| enable_acme_setup | Enable ACME storage setup for Let's Encrypt certificates | `bool` | `false` | no |
| iam_instance_profile | IAM instance profile name to attach to EC2 instances | `string` | `""` | no |
| instance_type | EC2 instance type | `string` | `"t3.large"` | no |
| replica_start_index | Starting index for replica numbering (Default: 1) | `number` | `1` | no |
| root_block_device_size | Root block device size in GB | `number` | `20` | no |
| security_group_ids | List of security group IDs to associate with the instances (used if not creating VPC) | `list(string)` | `[]` | no |
| subnet_ids | List of subnet IDs | `list(string)` | `[]` | no |
| user_data_override | Optional user data script to override the default Docker-based generation | `string` | `""` | no |
| user_data_overrides | Optional map of user data scripts to override the default Docker-based generation per instance key | `map(string)` | `{}` | no |
| vpc_id | VPC ID | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| instances | Map of all instances with their details |
| private_ips | Map of instance keys to private IP addresses |
| public_ips | Map of instance keys to public IP addresses |

<!-- END_TF_DOCS -->
