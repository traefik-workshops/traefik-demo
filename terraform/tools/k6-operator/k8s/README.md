# tools/k6-operator/k8s

Deploys the Grafana k6 Operator on Kubernetes via Helm.

## Example usage

```hcl
module "k6_operator" {
  source = "git::https://github.com/traefik/terraform-demo-modules.git//terraform/tools/k6-operator/k8s?ref=v3.2.0"

  name      = "k6-operator"
  namespace = "k6"
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
| `helm_release.k6_operator` | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| namespace | Namespace for the k6 deployment | `string` | n/a | yes |
| extra_values | Extra values to merge into the Helm chart values | `any` | `{}` | no |
| name | The name of the k6 release | `string` | `"k6-operator"` | no |
| node_selector | Node selector for pod scheduling | `map(string)` | `{}` | no |
| tolerations | Tolerations for pod scheduling | `list(object({key = string, operator = string, value = string, effect = string))` | `[]` | no |

<!-- END_TF_DOCS -->
