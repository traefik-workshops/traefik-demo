# tools/redis/k8s

Deploys Redis on Kubernetes via Helm with a configurable password and replica count.

## Example usage

```hcl
module "redis" {
  source = "git::https://github.com/traefik/traefik-demo.git//terraform/tools/redis/k8s?ref=v3.2.0"

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
|------|---------|
| helm | ~> 3.0 |

## Providers

| Name | Source | Version |
|------|--------|---------|
| helm | `hashicorp/helm` | `~> 3.0` |

## Resources

| Name | Type |
|------|------|
| `helm_release.redis` | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| namespace | Namespace for the Redis deployment | `string` | n/a | yes |
| extra_values | Extra values to merge into the Helm chart values | `any` | `{}` | no |
| name | The name of the redis release | `string` | `"traefik"` | no |
| password | Redis password | `string` | `"topsecretpassword"` | no |
| replicaCount | Number of replicas for the Redis deployment | `number` | `1` | no |

<!-- END_TF_DOCS -->
