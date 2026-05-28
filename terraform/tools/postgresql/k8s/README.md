# tools/postgresql/k8s

Deploys PostgreSQL on Kubernetes via Helm with a configurable password and database name.

## Example usage

```hcl
module "postgresql" {
  source = "git::https://github.com/traefik/traefik-demo.git//terraform/tools/postgresql/k8s?ref=v4.0.0"

  name      = "postgres"
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
| `helm_release.postgres` | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| namespace | Namespace for the Traefik Hub deployment | `string` | n/a | yes |
| database | Database name | `string` | `"postgres"` | no |
| extra_values | Extra values to merge into the Helm chart values | `any` | `{}` | no |
| name | The name of the traefik release | `string` | `"traefik"` | no |
| password | Redis password | `string` | `"topsecretpassword"` | no |

<!-- END_TF_DOCS -->
