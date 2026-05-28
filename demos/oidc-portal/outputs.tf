output "portal_url" {
  value       = "https://portal.${var.domain}"
  description = "Traefik Hub API Portal — Cognito-protected."
}
output "cognito_app_client_id" {
  value       = module.cognito.app_client_id
  description = "Use this in the Portal OIDC settings."
}
output "cognito_app_client_secret" {
  value       = module.cognito.app_client_secret
  description = "OIDC client secret — paste into the Portal config."
  sensitive   = true
}
output "demo_users" {
  value       = module.cognito.users
  description = "Seeded users with generated passwords (sensitive)."
  sensitive   = true
}
