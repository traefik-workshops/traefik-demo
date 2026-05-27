# ai/knative/k8s

Installs Knative Serving on a Kubernetes cluster (Helm + kubectl CRDs) for the AI Gateway demo.

## Example usage

```hcl
module "knative" {
  source = "git::https://github.com/traefik/terraform-demo-modules.git//terraform/ai/knative/k8s?ref=v3.2.0"

  namespace = "knative-serving"
}
```

## Prerequisites

- A working Kubernetes cluster with `helm` and `kubectl` providers configured.

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name | Version |
|------|---------|
| helm | ~> 3.0 |
| kubectl | ~> 1.0 |

## Providers

| Name | Source | Version |
|------|--------|---------|
| helm | `hashicorp/helm` | `~> 3.0` |
| kubectl | `gavinbunney/kubectl` | `~> 1.0` |

## Resources

| Name | Type |
|------|------|
| `helm_release.knative_operator` | resource |
| `kubernetes_namespace_v1.knative_serving` | resource |
| `kubectl_manifest.knative_serving` | resource |
| `kubectl_manifest.knative_serving_domain` | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| namespace | The namespace of the knative release | `string` | n/a | yes |
| ingress_domain | The external domain where knative will publish services. | `string` | `"demo.traefik.ai"` | no |
| name | The name of the knative release | `string` | `"knative"` | no |

<!-- END_TF_DOCS -->
