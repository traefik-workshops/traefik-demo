# ai/granite-guardian/runpod

Provisions an IBM Granite Guardian safety model pod on RunPod.

## Example usage

```hcl
module "granite_guardian" {
  source = "git::https://github.com/traefik/traefik-demo.git//terraform/ai/granite-guardian/runpod?ref=v4.0.0"

  runpod_api_key          = var.runpod_api_key
  hugging_face_api_key    = var.hugging_face_api_key
  enable_granite_guardian = true
}
```

## Prerequisites

- A RunPod account and API key.
- A Hugging Face account/token with access to the Granite Guardian model.

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
| <a name="input_hugging_face_api_key"></a> [hugging\_face\_api\_key](#input\_hugging\_face\_api\_key) | Hugging Face API key | `string` | n/a | yes |
| <a name="input_runpod_api_key"></a> [runpod\_api\_key](#input\_runpod\_api\_key) | RunPod API key | `string` | n/a | yes |
| <a name="input_enable_granite_guardian"></a> [enable\_granite\_guardian](#input\_enable\_granite\_guardian) | Enable Granite Guardian | `bool` | `false` | no |
| <a name="input_pod_type"></a> [pod\_type](#input\_pod\_type) | Pod type | `string` | `"NVIDIA A40"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_pods"></a> [pods](#output\_pods) | Map of created pods with their details |
<!-- END_TF_DOCS -->
