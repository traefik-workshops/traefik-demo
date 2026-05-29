# tools/redis/k8s

Deploys Redis on Kubernetes via Helm with a configurable password and replica count.

## Example usage

```hcl
module "redis" {
  source = "git::https://github.com/traefik/traefik-demo.git//terraform/tools/redis/k8s?ref=v4.0.0"

  name      = "redis"
  namespace = "data"
}
```

## Prerequisites

- A working Kubernetes cluster with the `helm` provider configured.

## Notes

- Default `password` is a demo value — override it for any non-throwaway deployment.

<!-- BEGIN_TF_DOCS -->


## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | ~> 3.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_helm"></a> [helm](#provider\_helm) | ~> 3.0 |

## Resources

| Name | Type |
| ---- | ---- |
| [helm_release.redis](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace for the Redis deployment | `string` | n/a | yes |
| <a name="input_extra_values"></a> [extra\_values](#input\_extra\_values) | Extra values to merge into the Helm chart values | `any` | `{}` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of the redis release | `string` | `"traefik"` | no |
| <a name="input_password"></a> [password](#input\_password) | Redis password. DEMO DEFAULT — override per environment. | `string` | `"topsecretpassword"` | no |
| <a name="input_replica_count"></a> [replica\_count](#input\_replica\_count) | Number of replicas for the Redis deployment | `number` | `1` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
