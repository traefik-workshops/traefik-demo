# ai/granite-guardian/runpod

Provisions an IBM Granite Guardian safety model pod on RunPod.

## Example usage

```hcl
module "granite_guardian" {
  source = "git::https://github.com/traefik/terraform-demo-modules.git//terraform/ai/granite-guardian/runpod?ref=v3.2.0"

  runpod_api_key          = var.runpod_api_key
  hugging_face_api_key    = var.hugging_face_api_key
  enable_granite_guardian = true
}
```

## Prerequisites

- A RunPod account and API key.
- A Hugging Face account/token with access to the Granite Guardian model.

## Notes

- See PROV-01 in [../../../ISSUES.md](../../../ISSUES.md) — this module is missing `required_providers`.

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
| enable_granite_guardian | Enable Granite Guardian | `bool` | `false` | no |
| pod_type | Pod type | `string` | `"NVIDIA A40"` | no |

## Outputs

| Name | Description |
|------|-------------|
| pods | Map of created pods with their details |

<!-- END_TF_DOCS -->
