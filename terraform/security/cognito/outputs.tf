output "user_pool_domain" {
  description = "The endpoint name of the Cognito User Pool"
  value       = aws_cognito_user_pool_domain.main.domain
}

output "user_pool_id" {
  description = "The ID of the Cognito User Pool"
  value       = aws_cognito_user_pool.pool.id
}

output "app_client_id" {
  description = "The ID of the Cognito App Client"
  value       = aws_cognito_user_pool_client.client.id
}

output "app_client_secret" {
  description = "The client secret of the Cognito App Client"
  value       = aws_cognito_user_pool_client.client.client_secret
  sensitive   = true
}

output "users" {
  description = "List of created users"
  value       = [for user in aws_cognito_user.users : user.username]
}
