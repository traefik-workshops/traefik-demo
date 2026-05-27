# =============================================================================
# ECS Traefik Deployment
# =============================================================================
# Uses extracted config from traefik/shared module (via Helm template).
# =============================================================================

locals {
  # Use extracted CLI arguments from Helm template
  # Uses centralized filtering to exclude Kubernetes-specific args
  traefik_arguments = module.config.extracted_cli_args_cloud

  # Use extracted environment variables
  traefik_envs = module.config.env_vars_list

  # Use shared module for image reference
  traefik_image = module.config.image_full

  # Build Docker labels including ports
  docker_labels = merge(var.extra_labels, {
    for name, port in module.config.ports :
    "traefik.http.routers.${name}.entrypoints" => name
    if try(port.expose.default, false)
    }, {
    "traefik.enable"                                           = "true"
    "traefik.http.routers.dashboard.rule"                      = module.config.dashboard_match_rule
    "traefik.http.routers.dashboard.entrypoints"               = module.config.dashboard_entrypoints[0]
    "traefik.http.services.dashboard.loadbalancer.server.port" = "8080"
  })
}

module "ecs" {
  source = "../../compute/aws/ecs"

  name = "traefik"
  clusters = {
    traefik = {
      apps = {
        traefik = {
          replicas           = module.config.replica_count
          port               = 80
          docker_image       = local.traefik_image
          docker_command     = join(" ", local.traefik_arguments)
          subnet_ids         = var.subnet_ids
          security_group_ids = var.security_group_ids
          labels             = local.docker_labels
        }
      }
    }
  }

  create_vpc = var.create_vpc
  vpc_id     = var.vpc_id
}
