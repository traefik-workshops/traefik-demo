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
| [null_resource.registry_auth_cleanup](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_ngc_token"></a> [ngc\_token](#input\_ngc\_token) | NVIDIA NGC API token | `string` | n/a | yes |
| <a name="input_runpod_api_key"></a> [runpod\_api\_key](#input\_runpod\_api\_key) | RunPod API key | `string` | n/a | yes |
| <a name="input_ngc_username"></a> [ngc\_username](#input\_ngc\_username) | NVIDIA NGC username (usually '$oauthtoken' for API auth) | `string` | `"$oauthtoken"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_registry_auth_id"></a> [registry\_auth\_id](#output\_registry\_auth\_id) | ID of the created registry auth |
<!-- END_TF_DOCS -->
