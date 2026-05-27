# security/entraid

Provisions an Azure AD (Entra ID) Application, a client secret, and a set of demo users.

## Example usage

```hcl
module "entraid" {
  source = "git::https://github.com/traefik/terraform-demo-modules.git//terraform/security/entraid?ref=v3.2.0"

  users         = ["admin", "support"]
  redirect_uris = ["https://demo.traefik.ai/callback"]
}
```

## Prerequisites

- Azure credentials with Entra ID app/user management permissions.

## Notes

- The user passwords are hardcoded in `main.tf` — see **SEC-04** in [../../ISSUES.md](../../ISSUES.md).

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name | Version |
|------|---------|
| azurerm | ~> 4.0 |
| azuread | ~> 3.0 |

## Providers

| Name | Source | Version |
|------|--------|---------|
| azurerm | `hashicorp/azurerm` | `~> 4.0` |
| azuread | `hashicorp/azuread` | `~> 3.0` |

## Resources

| Name | Type |
|------|------|
| `azuread_user.traefik_demo` | resource |
| `azuread_group.traefik_demo` | resource |
| `azuread_group_member.traefik_demo` | resource |
| `random_uuid.traefik_demo_permission_scope_id` | resource |
| `random_uuid.traefik_demo_app_role_id` | resource |
| `azuread_application.traefik_demo` | resource |
| `azuread_application_password.traefik_demo` | resource |
| `azuread_service_principal.traefik_demo` | resource |
| `azuread_app_role_assignment.traefik_demo` | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| redirect_uris | EntraID redirect URIs | `list(string)` | `[]` | no |
| users | EntraID users to be created | `list(string)` | `["admin","support"]` | no |

## Outputs

| Name | Description |
|------|-------------|
| application_client_id 🔒 | The client ID for the application |
| application_client_secret 🔒 | The client secret for the application |
| domain_name | The domain name of the Azure AD directory |
| tenant_id 🔒 | The tenant ID of the Azure AD directory |
| users | EntraID users created |

<!-- END_TF_DOCS -->
