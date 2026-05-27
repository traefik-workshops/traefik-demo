output "services" {
  description = "Map of all ECS services with their details"
  value = {
    for key, service in aws_ecs_service.service : key => {
      id                  = service.id
      name                = service.name
      cluster_name        = local.services_map[key].cluster_name
      app_name            = local.services_map[key].app_name
      replicas            = local.services_map[key].replicas
      task_definition_arn = aws_ecs_task_definition.service[key].arn
    }
  }
}
