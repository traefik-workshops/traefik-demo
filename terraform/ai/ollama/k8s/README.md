# ai/ollama/k8s

Deploys Ollama on a Kubernetes cluster via Helm and optionally pre-pulls a selection of models (Qwen, DeepSeek, Llama).

## Example usage

```hcl
module "ollama" {
  source = "git::https://github.com/traefik/traefik-demo.git//terraform/ai/ollama/k8s?ref=v3.2.0"

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
|------|---------|
| helm | ~> 3.0 |

## Providers

| Name | Source | Version |
|------|--------|---------|
| helm | `hashicorp/helm` | `~> 3.0` |

## Resources

| Name | Type |
|------|------|
| `helm_release.ollama` | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| enable_deepseek | Enable DeepSeek model | `bool` | `false` | no |
| enable_llama | Enable Llama model | `bool` | `false` | no |
| enable_qwen | Enable Qwen model | `bool` | `false` | no |
| name | The name of the milvus release | `string` | `"milvus"` | no |
| namespace | The namespace of the milvus release | `string` | `"milvus"` | no |

<!-- END_TF_DOCS -->
