# observability/grafana-tempo/k8s

Deploys Grafana Tempo on Kubernetes via Helm.

## Example usage

```hcl
module "tempo" {
  source = "git::https://github.com/traefik/terraform-demo-modules.git//terraform/observability/grafana-tempo/k8s?ref=v3.2.0"

  name      = "tempo"
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
| `helm_release.tempo` | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| namespace | Namespace for the Grafana deployment | `string` | n/a | yes |
| extra_values | Extra values to pass to the Grafana deployment. | `any` | `{}` | no |
| name | The name of the tempo release | `string` | `"tempo"` | no |
| tolerations | Tolerations for the Grafana deployment. | `list(object({key = string, operator = string, value = string, effect = string))` | `[]` | no |

<!-- END_TF_DOCS -->
