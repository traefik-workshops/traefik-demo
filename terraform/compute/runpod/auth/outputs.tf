output "registry_auth_id" {
  value       = data.external.registry_auth.result.id
  description = "ID of the created registry auth"
}
