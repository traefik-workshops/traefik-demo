# ai/knative/k8s

Installs Knative Serving on a Kubernetes cluster (Helm + kubectl CRDs) for the AI Gateway demo.

## Example usage

```hcl
module "knative" {
  source = "git::https://github.com/traefik/traefik-demo.git//terraform/ai/knative/k8s?ref=v4.0.0"

  namespace = "knative-serving"
}
```

## Prerequisites

- A working Kubernetes cluster with `helm` and `kubectl` providers configured.

<!-- BEGIN_TF_DOCS -->


## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | ~> 3.0 |
| <a name="requirement_kubectl"></a> [kubectl](#requirement\_kubectl) | ~> 1.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_helm"></a> [helm](#provider\_helm) | ~> 3.0 |
| <a name="provider_kubectl"></a> [kubectl](#provider\_kubectl) | ~> 1.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | ~> 2.0 |

## Resources

| Name | Type |
| ---- | ---- |
| [helm_release.knative_operator](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubectl_manifest.knative_serving](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/resources/manifest) | resource |
| [kubectl_manifest.knative_serving_domain](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/resources/manifest) | resource |
| [kubernetes_namespace_v1.knative_serving](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace_v1) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | The namespace of the knative release | `string` | n/a | yes |
| <a name="input_ingress_domain"></a> [ingress\_domain](#input\_ingress\_domain) | The external domain where knative will publish services. | `string` | `"demo.traefik.ai"` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of the knative release | `string` | `"knative"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_namespace"></a> [namespace](#output\_namespace) | Namespace Knative Serving was installed into. |
| <a name="output_operator_namespace"></a> [operator\_namespace](#output\_operator\_namespace) | Namespace where the Knative Operator lives. |
<!-- END_TF_DOCS -->
