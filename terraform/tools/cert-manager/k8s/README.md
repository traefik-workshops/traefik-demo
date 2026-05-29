# tools/cert-manager/k8s

Deploys cert-manager on Kubernetes via Helm.

## Example usage

```hcl
module "cert_manager" {
  source = "git::https://github.com/traefik/traefik-demo.git//terraform/tools/cert-manager/k8s?ref=v4.0.0"

  name      = "cert-manager"
  namespace = "cert-manager"
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
| [helm_release.cert_manager](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace for the cert-manager deployment | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the cert-manager release | `string` | `"cert-manager"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
