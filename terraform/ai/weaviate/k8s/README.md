# ai/weaviate/k8s

Deploys the Weaviate vector database into a Kubernetes cluster via Helm.

## Example usage

```hcl
module "weaviate" {
  source = "git::https://github.com/traefik/traefik-demo.git//terraform/ai/weaviate/k8s?ref=v4.0.0"

  namespace = "weaviate"
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
| [helm_release.weaviate](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | The namespace of the weaviate release | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the weaviate release | `string` | `"weaviate"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
