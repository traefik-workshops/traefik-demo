# Data source for latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-${var.ami_architecture}"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

locals {
  instances = flatten([
    for app_name, app_config in var.apps : [
      for replica_idx in range(app_config.replicas) : {
        app_name            = app_name
        replica_number      = replica_idx + var.replica_start_index
        subnet_ids          = length(app_config.subnet_ids) > 0 ? app_config.subnet_ids : var.subnet_ids
        instance_key        = "${app_name}-${replica_idx + var.replica_start_index}"
        port                = app_config.port
        docker_image        = app_config.docker_image
        docker_options      = app_config.docker_options
        container_arguments = app_config.container_arguments
        app_tags            = app_config.tags
      }
    ]
  ])

  # Convert to map for for_each with global index for even distribution
  instances_map = {
    for idx, inst in local.instances : inst.instance_key => merge(inst, {
      idx = idx
    })
  }
}

# Replacement trigger to avoid AWS provider bug with user_data_replace_on_change
resource "terraform_data" "replacement_trigger" {
  for_each = local.instances_map
  input = base64encode(
    try(var.user_data_overrides[each.key], null) != null ? var.user_data_overrides[each.key] : (
      var.user_data_override != "" ? var.user_data_override : "default"
    )
  )
}

module "vpc" {
  count  = var.create_vpc ? 1 : 0
  source = "../vpc"

  name           = "ec2-vpc"
  cidr           = "10.0.0.0/16"
  public_subnets = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

# Create EC2 instances for each app replica
resource "aws_instance" "ec2" {
  for_each = local.instances_map

  ami                         = data.aws_ami.amazon_linux_2023.id
  instance_type               = var.instance_type
  subnet_id                   = var.create_vpc ? module.vpc[0].public_subnet_ids[each.value.idx % length(module.vpc[0].public_subnet_ids)] : each.value.subnet_ids[each.value.idx % length(each.value.subnet_ids)]
  vpc_security_group_ids      = var.create_vpc ? module.vpc[0].security_group_ids : var.security_group_ids
  iam_instance_profile        = var.iam_instance_profile != "" ? var.iam_instance_profile : null
  associate_public_ip_address = var.associate_public_ip_address

  # Generate user data with app-specific Docker settings (unless overridden)
  user_data_base64 = try(var.user_data_overrides[each.key], null) != null ? base64encode(var.user_data_overrides[each.key]) : (
    var.user_data_override != "" ? base64encode(var.user_data_override) : base64encode(<<-EOF
    #!/bin/bash
    set -e
    
    # Update system and install Docker
    yum update -y
    yum install -y docker
    systemctl start docker
    systemctl enable docker
    %{if var.enable_acme_setup~}
    
    # Create ACME storage with correct permissions (when using Cloudflare DNS for certificates)
    mkdir -p /var/lib/docker/volumes/traefik-data/_data
    touch /var/lib/docker/volumes/traefik-data/_data/acme.json
    chmod 600 /var/lib/docker/volumes/traefik-data/_data/acme.json
    %{endif~}
    
    # Pull the Docker image
    docker pull ${each.value.docker_image}
    
    # Run the Docker container
    docker run -d \
      --name ${each.value.app_name}-${each.value.replica_number} \
      --restart always \
      ${each.value.docker_options} \
      ${each.value.docker_image} \
      ${each.value.container_arguments}
    
    # Log container status
    echo "Container ${each.value.app_name}-${each.value.replica_number} started successfully"
    docker ps
  EOF
    )
  )

  user_data_replace_on_change = false # We use replace_triggered_by instead to avoid AWS provider bug with user_data_replace_on_change

  tags = merge(
    var.common_tags,
    each.value.app_tags,
    {
      Name = each.key # Format: "app-name-replica-number" (e.g., "whoami-1")
    }
  )

  root_block_device {
    volume_size = var.root_block_device_size
    volume_type = "gp3"
  }

  lifecycle {
    ignore_changes = [ami]
    replace_triggered_by = [
      terraform_data.replacement_trigger[each.key]
    ]
  }
}
