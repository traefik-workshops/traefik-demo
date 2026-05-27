# compute/runpod/auth

Creates a RunPod registry auth (using NGC credentials) via the RunPod GraphQL API.

## Example usage

```hcl
module "runpod_auth" {
  source = "git::https://github.com/traefik/terraform-demo-modules.git//terraform/compute/runpod/auth?ref=v3.2.0"

  runpod_api_key = var.runpod_api_key
  ngc_token      = var.ngc_token
}
```

## Prerequisites

- A RunPod account and API key.
- An NVIDIA NGC API token.

## Notes

- See PROV-01 in [../../../ISSUES.md](../../../ISSUES.md) — this module is missing `required_providers` (uses `http`/`external`/`null` implicitly).

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
