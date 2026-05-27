# ai/NIMs/runpod

Provisions NVIDIA NIM safety microservices (Topic Control, Content Safety, Jailbreak Detection) on RunPod, gated by per-NIM enable flags.

## Example usage

```hcl
module "nims" {
  source = "git::https://github.com/traefik/terraform-demo-modules.git//terraform/ai/NIMs/runpod?ref=v3.2.0"

  runpod_api_key            = var.runpod_api_key
  ngc_token                 = var.ngc_token
  enable_topic_control_nim  = true
  enable_content_safety_nim = true
}
```

## Prerequisites

- A RunPod account and API key.
- An NVIDIA NGC account with access to the requested NIM container images.

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
| ngc_token | NVIDIA NGC API token | `string` | n/a | yes |
| runpod_api_key | RunPod API key | `string` | n/a | yes |
| enable_content_safety_nim | Configuration for Content Safety NIM | `bool` | `false` | no |
| enable_jailbreak_detection_nim | Configuration for Jailbreak Detection NIM | `bool` | `false` | no |
| enable_topic_control_nim | Configuration for Topic Control NIM | `bool` | `false` | no |
| ngc_username | NVIDIA NGC username (usually '$oauthtoken' for API auth) | `string` | `"$oauthtoken"` | no |
| pod_type | The type of pod to deploy (e.g., NVIDIA L40, NVIDIA A100, etc.) | `string` | `"NVIDIA A40"` | no |

## Outputs

| Name | Description |
|------|-------------|
| pods | Map of created pods with their details |

<!-- END_TF_DOCS -->
