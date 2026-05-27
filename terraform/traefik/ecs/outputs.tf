output "services" {
  description = "Map of ECS services with their details"
  value       = module.ecs.services
}
