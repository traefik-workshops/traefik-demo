# ai/NIMs/runpod

Provisions NVIDIA NIM safety microservices (Topic Control, Content Safety, Jailbreak Detection) on RunPod, gated by per-NIM enable flags.

## Example usage

```hcl
module "nims" {
  source = "git::https://github.com/traefik/traefik-demo.git//terraform/ai/NIMs/runpod?ref=v4.0.0"

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

<!-- BEGIN_TF_DOCS -->


## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |

## Providers

No providers.

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_ngc_token"></a> [ngc\_token](#input\_ngc\_token) | NVIDIA NGC API token | `string` | n/a | yes |
| <a name="input_runpod_api_key"></a> [runpod\_api\_key](#input\_runpod\_api\_key) | RunPod API key | `string` | n/a | yes |
| <a name="input_enable_content_safety_nim"></a> [enable\_content\_safety\_nim](#input\_enable\_content\_safety\_nim) | Configuration for Content Safety NIM | `bool` | `false` | no |
| <a name="input_enable_jailbreak_detection_nim"></a> [enable\_jailbreak\_detection\_nim](#input\_enable\_jailbreak\_detection\_nim) | Configuration for Jailbreak Detection NIM | `bool` | `false` | no |
| <a name="input_enable_topic_control_nim"></a> [enable\_topic\_control\_nim](#input\_enable\_topic\_control\_nim) | Configuration for Topic Control NIM | `bool` | `false` | no |
| <a name="input_ngc_username"></a> [ngc\_username](#input\_ngc\_username) | NVIDIA NGC username (usually '$oauthtoken' for API auth) | `string` | `"$oauthtoken"` | no |
| <a name="input_pod_type"></a> [pod\_type](#input\_pod\_type) | The type of pod to deploy (e.g., NVIDIA L40, NVIDIA A100, etc.) | `string` | `"NVIDIA A40"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_pods"></a> [pods](#output\_pods) | Map of created pods with their details |
<!-- END_TF_DOCS -->
