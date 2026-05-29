# ai/ollama/k8s

Deploys Ollama on a Kubernetes cluster via Helm and optionally pre-pulls a selection of models (Qwen, DeepSeek, Llama).

## Example usage

```hcl
module "ollama" {
  source = "git::https://github.com/traefik/traefik-demo.git//terraform/ai/ollama/k8s?ref=v4.0.0"

  name        = "ollama"
  namespace   = "ollama"
  enable_qwen = true
}
```

## Prerequisites

- A working Kubernetes cluster with the `helm` provider configured.

## Notes

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
| [helm_release.ollama](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_enable_deepseek"></a> [enable\_deepseek](#input\_enable\_deepseek) | Enable DeepSeek model | `bool` | `false` | no |
| <a name="input_enable_llama"></a> [enable\_llama](#input\_enable\_llama) | Enable Llama model | `bool` | `false` | no |
| <a name="input_enable_qwen"></a> [enable\_qwen](#input\_enable\_qwen) | Enable Qwen model | `bool` | `false` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the Ollama Helm release. | `string` | `"ollama"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace for the Ollama Helm release. | `string` | `"ollama"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
