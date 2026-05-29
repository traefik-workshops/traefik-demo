# security/cognito

Provisions an AWS Cognito User Pool, a domain, an App Client, and a set of demo users.

## Example usage

```hcl
module "cognito" {
  source = "git::https://github.com/traefik/traefik-demo.git//terraform/security/cognito?ref=v4.0.0"

  users         = ["admin", "support"]
  redirect_uris = ["https://demo.traefik.ai/callback"]
}
```

## Prerequisites

- AWS credentials with Cognito permissions.

## Notes

<!-- BEGIN_TF_DOCS -->


## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0, < 7.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0, < 7.0 |

## Resources

| Name | Type |
| ---- | ---- |
| [aws_cognito_user.users](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user) | resource |
| [aws_cognito_user_group.groups](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_group) | resource |
| [aws_cognito_user_in_group.user_group_assignments](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_in_group) | resource |
| [aws_cognito_user_pool.pool](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool) | resource |
| [aws_cognito_user_pool_client.client](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool_client) | resource |
| [aws_cognito_user_pool_domain.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool_domain) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_redirect_uris"></a> [redirect\_uris](#input\_redirect\_uris) | Allowed callback URL for the authentication flow | `list(string)` | `[]` | no |
| <a name="input_user_password"></a> [user\_password](#input\_user\_password) | Initial password assigned to every created Cognito user. Demo default — override for anything beyond ephemeral PoCs. | `string` | `"topsecretpassword"` | no |
| <a name="input_users"></a> [users](#input\_users) | List of Cognito users to be created | `list(string)` | <pre>[<br/>  "admin",<br/>  "support"<br/>]</pre> | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_app_client_id"></a> [app\_client\_id](#output\_app\_client\_id) | The ID of the Cognito App Client |
| <a name="output_app_client_secret"></a> [app\_client\_secret](#output\_app\_client\_secret) | The client secret of the Cognito App Client |
| <a name="output_user_pool_domain"></a> [user\_pool\_domain](#output\_user\_pool\_domain) | The endpoint name of the Cognito User Pool |
| <a name="output_user_pool_id"></a> [user\_pool\_id](#output\_user\_pool\_id) | The ID of the Cognito User Pool |
| <a name="output_users"></a> [users](#output\_users) | List of created users |
<!-- END_TF_DOCS -->
