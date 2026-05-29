# security/entraid

Provisions an Azure AD (Entra ID) Application, a client secret, and a set of demo users.

## Example usage

```hcl
module "entraid" {
  source = "git::https://github.com/traefik/traefik-demo.git//terraform/security/entraid?ref=v4.0.0"

  users         = ["admin", "support"]
  redirect_uris = ["https://demo.traefik.ai/callback"]
}
```

## Prerequisites

- Azure credentials with Entra ID app/user management permissions.

## Notes

<!-- BEGIN_TF_DOCS -->


## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | ~> 3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | ~> 3.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 4.0 |
| <a name="provider_random"></a> [random](#provider\_random) | ~> 3.0 |

## Resources

| Name | Type |
| ---- | ---- |
| [azuread_app_role_assignment.traefik_demo](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/app_role_assignment) | resource |
| [azuread_application.traefik_demo](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application) | resource |
| [azuread_application_password.traefik_demo](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application_password) | resource |
| [azuread_group.traefik_demo](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/group) | resource |
| [azuread_group_member.traefik_demo](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/group_member) | resource |
| [azuread_service_principal.traefik_demo](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/service_principal) | resource |
| [azuread_user.traefik_demo](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/user) | resource |
| [random_uuid.traefik_demo_app_role_id](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/uuid) | resource |
| [random_uuid.traefik_demo_permission_scope_id](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/uuid) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_redirect_uris"></a> [redirect\_uris](#input\_redirect\_uris) | EntraID redirect URIs | `list(string)` | `[]` | no |
| <a name="input_user_password"></a> [user\_password](#input\_user\_password) | Initial password assigned to every created EntraID user. Demo default — override for anything beyond ephemeral PoCs. | `string` | `"topsecretpassword"` | no |
| <a name="input_users"></a> [users](#input\_users) | EntraID users to be created | `list(string)` | <pre>[<br/>  "admin",<br/>  "support"<br/>]</pre> | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_application_client_id"></a> [application\_client\_id](#output\_application\_client\_id) | The client ID for the application |
| <a name="output_application_client_secret"></a> [application\_client\_secret](#output\_application\_client\_secret) | The client secret for the application |
| <a name="output_domain_name"></a> [domain\_name](#output\_domain\_name) | The domain name of the Azure AD directory |
| <a name="output_tenant_id"></a> [tenant\_id](#output\_tenant\_id) | The tenant ID of the Azure AD directory |
| <a name="output_users"></a> [users](#output\_users) | EntraID users created |
<!-- END_TF_DOCS -->
