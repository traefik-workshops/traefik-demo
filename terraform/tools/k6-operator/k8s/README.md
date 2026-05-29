# tools/k6-operator/k8s

Deploys the Grafana k6 Operator on Kubernetes via Helm.

## Example usage

```hcl
module "k6_operator" {
  source = "git::https://github.com/traefik/traefik-demo.git//terraform/tools/k6-operator/k8s?ref=v4.0.0"

  name      = "k6-operator"
  namespace = "k6"
}
```

## Prerequisites

- A working Kubernetes cluster with the `helm` provider configured.

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
| [helm_release.k6_operator](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace for the k6 deployment | `string` | n/a | yes |
| <a name="input_extra_values"></a> [extra\_values](#input\_extra\_values) | Extra values to merge into the Helm chart values | `any` | `{}` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of the k6 release | `string` | `"k6-operator"` | no |
| <a name="input_node_selector"></a> [node\_selector](#input\_node\_selector) | Node selector for pod scheduling | `map(string)` | `{}` | no |
| <a name="input_tolerations"></a> [tolerations](#input\_tolerations) | Tolerations for pod scheduling | <pre>list(object({<br/>    key      = string<br/>    operator = string<br/>    value    = string<br/>    effect   = string<br/>  }))</pre> | `[]` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
