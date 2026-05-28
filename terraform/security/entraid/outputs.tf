data "azurerm_client_config" "traefik_demo" {}

output "tenant_id" {
  sensitive   = true
  description = "The tenant ID of the Azure AD directory"
  value       = data.azurerm_client_config.traefik_demo.tenant_id
}

output "application_client_id" {
  sensitive   = true
  description = "The client ID for the application"
  value       = azuread_application.traefik_demo.client_id
}

output "application_client_secret" {
  sensitive   = true
  description = "The client secret for the application"
  value       = azuread_application_password.traefik_demo.value
}

output "users" {
  description = "EntraID users created"
  value       = [for user in azuread_user.traefik_demo : user.user_principal_name]
}

output "domain_name" {
  description = "The domain name of the Azure AD directory"
  value       = local.domain_name
}
