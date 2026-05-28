# compute/runpod/auth

Creates a RunPod registry auth (using NGC credentials) via the RunPod GraphQL API.

## Example usage

```hcl
module "runpod_auth" {
  source = "git::https://github.com/traefik/traefik-demo.git//terraform/compute/runpod/auth?ref=v4.0.0"

  runpod_api_key = var.runpod_api_key
  ngc_token      = var.ngc_token
}
```

## Prerequisites

- A RunPod account and API key.
- An NVIDIA NGC API token.

## Notes

<!-- BEGIN_TF_DOCS -->

## Resources

| Name | Type |
|------|------|
| `null_resource.registry_auth_cleanup` | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| ngc_token | NVIDIA NGC API token | `string` | n/a | yes |
| runpod_api_key | RunPod API key | `string` | n/a | yes |
| ngc_username | NVIDIA NGC username (usually '$oauthtoken' for API auth) | `string` | `"$oauthtoken"` | no |

## Outputs

| Name | Description |
|------|-------------|
| registry_auth_id | ID of the created registry auth |

<!-- END_TF_DOCS -->
