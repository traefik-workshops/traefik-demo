output "registry_ip" {
  description = "Registry ip."
  value       = terraform_data.registry_health_check.input
}

output "registry_url" {
  description = "Registry url."
  value       = "http://${terraform_data.registry_health_check.input}:5000"
}
