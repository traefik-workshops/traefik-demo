# compute/aws/eks

Provisions an EKS cluster (and node groups) via the upstream community EKS module, with demo-friendly defaults.

## Example usage

```hcl
module "eks" {
  source = "git::https://github.com/traefik/terraform-demo-modules.git//terraform/compute/aws/eks?ref=v3.2.0"

  cluster_name     = "demo"
  cluster_location = "us-west-2"
  eks_version      = "1.30"
}
```

## Prerequisites

- AWS credentials with EKS/EC2/IAM permissions.
- `kubectl` on PATH if `update_kubeconfig = true`.

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
| `aws_eks_addon.traefik_demo` | resource |
| `null_resource.eks_cluster` | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cluster_name | EKS cluster name. | `string` | n/a | yes |
| cluster_location | EKS cluster location. | `string` | `"us-west-1"` | no |
| cluster_node_ami_type | EKS cluster AMI Type. | `string` | `"AL2023_x86_64_STANDARD"` | no |
| cluster_node_count | Number of nodes for the cluster. | `number` | `1` | no |
| cluster_node_type | Default machine type for cluster | `string` | `"t3.medium"` | no |
| create_vpc | Create VPC if vpc_id is not provided | `bool` | `true` | no |
| eks_version | EKS cluster version. | `string` | `""` | no |
| private_subnet_ids | Private subnets for the cluster. | `list(string)` | `[]` | no |
| public_subnet_ids | Public subnets for the cluster. | `list(string)` | `[]` | no |
| update_kubeconfig | Update kubeconfig after cluster creation | `bool` | `true` | no |
| vpc_id | VPC ID for the cluster. | `string` | `""` | no |
| worker_nodes | Worker node pool definitions. Each entry creates a dedicated node group with the given label and taint. | `list(object({label = string, taint = string, count = number))` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| cluster_ca_certificate 🔒 | EKS cluster CA certificate |
| cluster_endpoint | EKS cluster host |
| cluster_security_group_id | Security group ID attached to the EKS cluster |
| node_security_group_id | Security group ID attached to the EKS worker nodes |
| token 🔒 | EKS cluster auth token |

<!-- END_TF_DOCS -->
