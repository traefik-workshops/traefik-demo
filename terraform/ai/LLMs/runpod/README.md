# ai/LLMs/runpod

Provisions a set of LLM pods (Llama 3.1 8B, GPT OSS 20B) on RunPod, gated by per-model enable flags.

## Example usage

```hcl
module "llms" {
  source = "git::https://github.com/traefik/traefik-demo.git//terraform/ai/LLMs/runpod?ref=v4.0.0"

  runpod_api_key       = var.runpod_api_key
  hugging_face_api_key = var.hugging_face_api_key
  enable_llama31_8b    = true
}
```

## Prerequisites

- A RunPod account and API key.
- A Hugging Face account/token with access to the requested model weights.

## Notes

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.3.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| hugging_face_api_key 🔒 | Hugging Face API key | `string` | n/a | yes |
| runpod_api_key | RunPod API key | `string` | n/a | yes |
| enable_gpt_oss_20b | Enable GPT OSS 20B | `bool` | `false` | no |
| enable_llama31_8b | Enable Llama31 8B | `bool` | `false` | no |
| pod_type | Pod type | `string` | `"NVIDIA A40"` | no |

## Outputs

| Name | Description |
|------|-------------|
| pods | Map of created pods with their details |

<!-- END_TF_DOCS -->
