# security/cognito

Provisions an AWS Cognito User Pool, a domain, an App Client, and a set of demo users.

## Example usage

```hcl
module "cognito" {
  source = "git::https://github.com/traefik/terraform-demo-modules.git//terraform/security/cognito?ref=v3.2.0"

  users         = ["admin", "support"]
  redirect_uris = ["https://demo.traefik.ai/callback"]
}
```

## Prerequisites

- AWS credentials with Cognito permissions.

## Notes

- The admin user password is hardcoded in `main.tf` — see **SEC-03** in [../../ISSUES.md](../../ISSUES.md).

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name | Version |
|------|---------|
| aws | ~> 6.0 |

## Providers

| Name | Source | Version |
|------|--------|---------|
| aws | `hashicorp/aws` | `~> 6.0` |

## Resources

| Name | Type |
|------|------|
| `aws_cognito_user_pool.pool` | resource |
| `aws_cognito_user_pool_client.client` | resource |
| `aws_cognito_user_pool_domain.main` | resource |
| `aws_cognito_user.users` | resource |
| `aws_cognito_user_group.groups` | resource |
| `aws_cognito_user_in_group.user_group_assignments` | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| redirect_uris | Allowed callback URL for the authentication flow | `list(string)` | `[]` | no |
| users | List of Cognito users to be created | `list(string)` | `["admin","support"]` | no |

## Outputs

| Name | Description |
|------|-------------|
| app_client_id | The ID of the Cognito App Client |
| app_client_secret 🔒 | The client secret of the Cognito App Client |
| user_pool_domain | The endpoint name of the Cognito User Pool |
| user_pool_id | The ID of the Cognito User Pool |
| users | List of created users |

<!-- END_TF_DOCS -->
