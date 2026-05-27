output "deployments" {
  description = "Map of all Kubernetes deployments"
  value = {
    for name, deployment in kubernetes_deployment_v1.echo : name => {
      name      = deployment.metadata[0].name
      namespace = deployment.metadata[0].namespace
      replicas  = deployment.spec[0].replicas
    }
  }
}

output "services" {
  description = "Map of all Kubernetes services"
  value = {
    for name, service in kubernetes_service_v1.echo : name => {
      name      = service.metadata[0].name
      namespace = service.metadata[0].namespace
      type      = service.spec[0].type
      port      = service.spec[0].port[0].port
    }
  }
}
