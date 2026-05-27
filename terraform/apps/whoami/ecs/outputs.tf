output "services" {
  description = "Map of ECS services"
  value       = module.echo_services.services
}
