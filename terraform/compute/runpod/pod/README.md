# compute/runpod/pod

Creates a set of RunPod pods from a map definition, optionally using a registry auth for private images and forwarding HuggingFace / NGC tokens.

## Example usage

```hcl
module "pods" {
  source = "git::https://github.com/traefik/traefik-demo.git//terraform/compute/runpod/pod?ref=v3.2.0"

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

## Resources

| Name | Type |
|------|------|
| `null_resource.pods_cleanup` | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| pods | n/a | `any` | n/a | yes |
| runpod_api_key 🔒 | RunPod API key | `string` | n/a | yes |
| hugging_face_api_key 🔒 | Hugging Face API key | `string` | `""` | no |
| ngc_token 🔒 | NVIDIA NGC API token | `string` | `""` | no |
| registry_auth_id | ID of the registry auth | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| pods | Map of created pods with their details |

<!-- END_TF_DOCS -->
