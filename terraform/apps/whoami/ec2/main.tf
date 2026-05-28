# Use compute/ec2 module with apps mode
module "cloud_init" {
  for_each = var.apps
  source   = "../cloud-init"

  whoami_version = var.whoami_version
  arch           = var.ami_architecture == "x86_64" ? "amd64" : var.ami_architecture
  port           = each.value.port
}

locals {
  apps = {
    for app_name, app_config in var.apps : app_name => merge(
      app_config,
      {
        # Docker config is ignored when user_data_overrides is provided
        docker_image   = "traefik/whoami:${var.whoami_version}"
        docker_options = ""
      }
    )
  }

  # Replicate logic to generate instance keys locally to map user_data
  instance_keys = flatten([
    for app_name, app_config in var.apps : [
      for replica_idx in range(app_config.replicas) : {
        key      = "${app_name}-${replica_idx + 1}"
        app_name = app_name
      }
    ]
  ])

  user_data_overrides = {
    for item in local.instance_keys : item.key => module.cloud_init[item.app_name].rendered
  }
}

module "echo_instances" {
  source = "../../../compute/aws/ec2"

  # Pass through apps configuration with echo config
  apps               = local.apps
  instance_type      = var.instance_type
  common_tags        = var.common_tags
  create_vpc         = var.create_vpc
  vpc_id             = var.vpc_id
  subnet_ids         = var.subnet_ids
  security_group_ids = var.security_group_ids

  user_data_overrides = local.user_data_overrides
  ami_architecture    = var.ami_architecture
}
