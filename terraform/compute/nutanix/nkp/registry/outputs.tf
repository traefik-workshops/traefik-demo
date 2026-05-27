output "registry_ip" {
  value = terraform_data.registry_health_check.input
}

output "registry_url" {
  value = "http://${terraform_data.registry_health_check.input}:5000"
}
