# Flatten clusters and apps into individual services
locals {
  # Create a flat list of services: [{cluster_name, app_name, config}, ...]
  services = flatten([
    for cluster_name, cluster_config in var.clusters : [
      for app_name, app_config in cluster_config.apps : {
        cluster_name       = cluster_name
        app_name           = app_name
        service_key        = "${cluster_name}-${app_name}"
        replicas           = app_config.replicas
        port               = app_config.port
        docker_image       = app_config.docker_image
        docker_command     = app_config.docker_command
        environment        = app_config.environment
        app_labels         = app_config.labels
        subnet_ids         = app_config.subnet_ids
        security_group_ids = app_config.security_group_ids
      }
    ]
  ])

  # Convert to map for for_each with global index for even distribution
  services_map = {
    for idx, svc in local.services : svc.service_key => merge(svc, {
      idx        = idx
      subnet_ids = [for i in range(length(svc.subnet_ids)) : svc.subnet_ids[(idx + i) % length(svc.subnet_ids)]]
    })
  }

  # Get unique cluster names
  cluster_names = distinct([for svc in local.services : svc.cluster_name])
}

module "vpc" {
  count  = var.create_vpc ? 1 : 0
  source = "../vpc"

  name           = "ecs-vpc"
  cidr           = "10.0.0.0/16"
  public_subnets = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

}

# Create ECS clusters
resource "aws_ecs_cluster" "cluster" {
  for_each = toset(local.cluster_names)

  name = each.value
}

# Create IAM role for ECS task execution
resource "aws_iam_role" "ecs_task_execution" {
  name = "${var.name}-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Create ECS task definitions
resource "aws_ecs_task_definition" "service" {
  for_each = local.services_map

  family                   = "${each.value.cluster_name}-${each.value.app_name}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  cpu                      = "256"
  memory                   = "512"

  container_definitions = jsonencode([
    merge(
      {
        name      = each.value.app_name
        image     = each.value.docker_image
        essential = true

        portMappings = [
          {
            containerPort = each.value.port
            protocol      = "tcp"
          }
        ]

        dockerLabels = merge(
          var.common_labels,
          each.value.app_labels
        )
      },
      each.value.docker_command != "" ? {
        command = split(" ", each.value.docker_command)
      } : {},
      length(each.value.environment) > 0 ? {
        environment = [
          for key, value in each.value.environment : {
            name  = key
            value = value
          }
        ]
      } : {}
    )
  ])
}

# Create ECS services
resource "aws_ecs_service" "service" {
  for_each = local.services_map

  name            = each.value.app_name
  cluster         = aws_ecs_cluster.cluster[each.value.cluster_name].id
  task_definition = aws_ecs_task_definition.service[each.key].arn
  desired_count   = each.value.replicas
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.create_vpc ? module.vpc[0].public_subnet_ids : each.value.subnet_ids
    security_groups  = var.create_vpc ? module.vpc[0].security_group_ids : each.value.security_group_ids
    assign_public_ip = false
  }
}

