# observability/grafana-loki/k8s

Deploys Grafana Loki on Kubernetes via Helm.

## Example usage

```hcl
module "loki" {
  source = "git::https://github.com/traefik/traefik-demo.git//terraform/observability/grafana-loki/k8s?ref=v3.2.0"

  name      = "loki"
  namespace = "observability"
}
```

## Prerequisites

- A working Kubernetes cluster with the `helm` provider configured.

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
| `helm_release.loki` | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| namespace | Namespace for the Grafana deployment | `string` | n/a | yes |
| extra_values | Extra values to pass to the Grafana deployment. | `any` | `{}` | no |
| name | The name of the loki release | `string` | `"loki"` | no |
| tolerations | Tolerations for the Grafana deployment. | `list(object({key = string, operator = string, value = string, effect = string))` | `[]` | no |

<!-- END_TF_DOCS -->
