# compute/runpod/pod

Creates a set of RunPod pods from a map definition, optionally using a registry auth for private images and forwarding HuggingFace / NGC tokens.

## Example usage

```hcl
module "pods" {
  source = "git::https://github.com/traefik/traefik-demo.git//terraform/compute/runpod/pod?ref=v4.0.0"

  runpod_api_key = var.runpod_api_key
  pods = {
    "whoami" = {
      name      = "whoami"
      image     = "traefik/whoami:latest"
      pod_type  = "NVIDIA A40"
    }
  }
}
```

## Prerequisites

- A RunPod account and API key.

## Notes

<!-- BEGIN_TF_DOCS -->


## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_external"></a> [external](#requirement\_external) | ~> 2.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | ~> 3.2 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_external"></a> [external](#provider\_external) | ~> 2.0 |
| <a name="provider_null"></a> [null](#provider\_null) | ~> 3.2 |

## Resources

| Name | Type |
| ---- | ---- |
| [null_resource.pods_cleanup](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_pods"></a> [pods](#input\_pods) | Map of RunPod pod definitions to create, keyed by an arbitrary id. Each value carries the fields the `manage_pod.sh` script consumes: `name`, `image`, `tag`, `command`, `pod_type`. Typed as `any` because the upstream `runpodctl` schema evolves — validate at the call site. | `any` | n/a | yes |
| <a name="input_runpod_api_key"></a> [runpod\_api\_key](#input\_runpod\_api\_key) | RunPod API key | `string` | n/a | yes |
| <a name="input_hugging_face_api_key"></a> [hugging\_face\_api\_key](#input\_hugging\_face\_api\_key) | Hugging Face API key | `string` | `""` | no |
| <a name="input_ngc_token"></a> [ngc\_token](#input\_ngc\_token) | NVIDIA NGC API token | `string` | `""` | no |
| <a name="input_registry_auth_id"></a> [registry\_auth\_id](#input\_registry\_auth\_id) | ID of the registry auth | `string` | `""` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_pods"></a> [pods](#output\_pods) | Map of created pods with their details |
<!-- END_TF_DOCS -->
