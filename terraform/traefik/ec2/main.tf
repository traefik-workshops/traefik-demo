# =============================================================================
# EC2 Traefik Deployment
# =============================================================================
# Uses extracted config from traefik/shared module (via Helm template).
# =============================================================================

locals {
  # Use extracted CLI arguments from Helm template (includes file provider if configured)
  # Filter out placeholder token arg to avoid duplicates with manual injection in Systemd unit
  cli_arguments = [
    for arg in module.config.extracted_cli_args_cloud :
    arg if !startswith(arg, "--hub.token=")
  ]

  # Merge standard env vars with explicit HUB_TOKEN injection (Nutanix pattern)
  # Filter out K8s-specific env vars (like valueFrom maps) that don't belong on a VM
  env_vars_list = concat(
    module.config.env_vars_list,
    module.config.traefik_hub_token != "" ? [{ name = "HUB_TOKEN", value = module.config.traefik_hub_token }] : []
  )

  # Normalize performance tuning with defaults
  performance_tuning = {
    limit_nofile        = coalesce(try(var.performance_tuning.limit_nofile, null), 500000)
    tcp_tw_reuse        = coalesce(try(var.performance_tuning.tcp_tw_reuse, null), 1)
    tcp_timestamps      = coalesce(try(var.performance_tuning.tcp_timestamps, null), 1)
    rmem_max            = coalesce(try(var.performance_tuning.rmem_max, null), 16777216)
    wmem_max            = coalesce(try(var.performance_tuning.wmem_max, null), 16777216)
    somaxconn           = coalesce(try(var.performance_tuning.somaxconn, null), 4096)
    netdev_max_backlog  = coalesce(try(var.performance_tuning.netdev_max_backlog, null), 4096)
    ip_local_port_range = coalesce(try(var.performance_tuning.ip_local_port_range, null), "1024 65535")
    gomaxprocs          = coalesce(try(var.performance_tuning.gomaxprocs, null), 0)
    gogc                = coalesce(try(var.performance_tuning.gogc, null), 100)
    numa_node           = coalesce(try(var.performance_tuning.numa_node, null), -1)
  }

  # Generate unique user_data for each replica
  user_data_overrides = {
    for i in range(module.config.replica_count) :
    "traefik-${i + 1}" => templatefile("${path.module}/../cloud-init/cloud-init.tpl", {
      traefik_hub_version  = module.config.image_tag
      arch                 = var.ami_architecture
      cli_arguments        = local.cli_arguments
      env_vars             = local.env_vars_list
      file_provider_config = var.file_provider_config
      extra_files          = var.extra_files
      performance_tuning   = local.performance_tuning
      otlp_address         = module.config.otlp_endpoint
      instance_name        = "traefik-${i + 1}" # Explicit unique name as requested
      dashboard_config     = ""                 # Optional
      vip                  = ""                 # Optional
      keepalived_priority  = 100                # Optional
      network_interface    = "ens3"             # Optional
      dns_traefiker        = var.dns_traefiker
      enable_preview_mode  = var.enable_preview_mode
      preview_image        = module.config.image_full
    })
  }

  # Hash of performance tuning for lifestyle triggers
  performance_tuning_hash = sha256(jsonencode(local.performance_tuning))

  primary_ip = coalesce(
    try(values(aws_eip.traefik)[0].public_ip, ""),
    try(values(module.ec2_primary.public_ips)[0], ""),
    try(values(module.ec2_primary.private_ips)[0], ""),
  )
}

module "ec2_primary" {
  source = "../../compute/aws/ec2"

  apps = {
    traefik = {
      replicas   = 1
      subnet_ids = var.subnet_ids
    }
  }

  instance_type          = var.instance_type
  ami_architecture       = var.ami_architecture
  create_vpc             = var.create_vpc
  vpc_id                 = var.vpc_id
  security_group_ids     = var.security_group_ids
  iam_instance_profile   = var.iam_instance_profile
  enable_acme_setup      = module.config.cloudflare_dns.enabled
  root_block_device_size = var.root_block_device_size

  common_tags = merge(var.extra_tags, {
    "Name"                                                     = "traefik"
    "traefik.enable"                                           = "true"
    "traefik.http.routers.dashboard.rule"                      = module.config.dashboard_match_rule
    "traefik.http.routers.dashboard.entrypoints"               = module.config.dashboard_entrypoints[0]
    "traefik.http.services.dashboard.loadbalancer.server.port" = "8080"
    "traefik.performance_hash"                                 = local.performance_tuning_hash
  })

  # Pass only primary user data
  user_data_overrides = {
    "traefik-1" = local.user_data_overrides["traefik-1"]
  }
}

resource "aws_eip" "traefik" {
  for_each = var.create_eip ? module.ec2_primary.instances : {}

  domain   = "vpc"
  instance = each.value.instance_id

  tags = merge(var.extra_tags, {
    Name = "traefik-eip-${each.key}"
  })

  depends_on = [module.ec2_primary]
}

# Health check: wait for Primary Traefik to be ready
resource "null_resource" "wait_for_traefik" {
  count = var.wait_for_ready || var.sync_acme ? 1 : 0

  triggers = {
    instance_ids = join(",", [for i in module.ec2_primary.instances : i.instance_id])
    primary_ip   = local.primary_ip
  }

  provisioner "local-exec" {
    command = <<-EOF
      PRIMARY_IP="${local.primary_ip}"
      TIMEOUT=${var.wait_timeout}

      if [ -z "$PRIMARY_IP" ]; then
        echo "WARNING: No IP found for primary Traefik. Skipping wait."
        exit 0
      fi

      echo "Waiting for primary Traefik at $PRIMARY_IP..."
      ELAPSED=0
      while [ $ELAPSED -lt $TIMEOUT ]; do
        HTTP_CODE=$(curl -s -o /dev/null -w "%%{http_code}" --connect-timeout 5 http://$PRIMARY_IP:80/ 2>/dev/null || echo "000")
        if [ "$HTTP_CODE" = "404" ]; then
          echo "  Primary Traefik at $PRIMARY_IP is ready! (HTTP $HTTP_CODE)"
          break
        fi
        echo "  Waiting for HTTP 404... (Current: $HTTP_CODE, $ELAPSED s)"
        sleep 5
        ELAPSED=$((ELAPSED + 5))
      done

      if [ $ELAPSED -ge $TIMEOUT ]; then
        echo "ERROR: Primary Traefik at $PRIMARY_IP did not respond within $TIMEOUT seconds"
        exit 1
      fi
    EOF
  }

  depends_on = [module.ec2_primary, aws_eip.traefik]
}

# ACME Synchronization: Wait for the primary instance to obtain the certificate
resource "null_resource" "wait_for_acme_primary" {
  count = var.sync_acme ? 1 : 0

  triggers = {
    instance_ids  = join(",", [for i in module.ec2_primary.instances : i.instance_id])
    primary_ip    = local.primary_ip
    traefik_ready = null_resource.wait_for_traefik[0].id
  }

  provisioner "local-exec" {
    command = <<-EOF
      PRIMARY_IP="${local.primary_ip}"

      if [ -z "$PRIMARY_IP" ]; then
        echo "ERROR: Primary IP not found. Cannot wait for ACME."
        exit 1
      fi

      export SSHPASS='topsecretpassword'
      SSH_OPTS="-o StrictHostKeyChecking=no -o PreferredAuthentications=password -o ConnectTimeout=10"

      echo "Waiting for primary Traefik ($PRIMARY_IP) to obtain ACME certificate..."
      TIMEOUT=${var.wait_timeout}
      ELAPSED=0
      DOMAIN="${nonsensitive(module.config.cloudflare_dns.domain)}"

      while [ $ELAPSED -lt $TIMEOUT ]; do
        if sshpass -e ssh $SSH_OPTS traefiker@$PRIMARY_IP "sudo grep -q '$DOMAIN' /data/acme.json 2>/dev/null"; then
          echo "  Certificate found on $PRIMARY_IP!"
          exit 0
        fi
        echo "  Waiting for certificate ($DOMAIN) on $PRIMARY_IP... ($ELAPSED s)"
        sleep 10
        ELAPSED=$((ELAPSED + 10))
      done

      echo "ERROR: Primary Traefik did not obtain certificate within $TIMEOUT seconds"
      exit 1
    EOF
  }

  depends_on = [null_resource.wait_for_acme_primary]
}

module "ec2_secondary" {
  source = "../../compute/aws/ec2"
  count  = module.config.replica_count > 1 ? 1 : 0

  apps = {
    traefik = {
      replicas   = module.config.replica_count - 1
      subnet_ids = var.subnet_ids
    }
  }

  replica_start_index = 2

  instance_type          = var.instance_type
  ami_architecture       = var.ami_architecture
  create_vpc             = var.create_vpc
  vpc_id                 = var.vpc_id
  security_group_ids     = var.security_group_ids
  iam_instance_profile   = var.iam_instance_profile
  enable_acme_setup      = module.config.cloudflare_dns.enabled
  root_block_device_size = var.root_block_device_size

  common_tags = merge(var.extra_tags, {
    "Name"                                                     = "traefik"
    "traefik.enable"                                           = "true"
    "traefik.http.routers.dashboard.rule"                      = module.config.dashboard_match_rule
    "traefik.http.routers.dashboard.entrypoints"               = module.config.dashboard_entrypoints[0]
    "traefik.http.services.dashboard.loadbalancer.server.port" = "8080"
    "traefik.performance_hash"                                 = local.performance_tuning_hash
  })

  # Map primary user data indices to secondary naming scheme
  user_data_overrides = {
    for i in range(1, module.config.replica_count) :
    "traefik-${i + 1}" => local.user_data_overrides["traefik-${i + 1}"]
  }

  depends_on = [null_resource.wait_for_acme_primary]
}

resource "null_resource" "sync_acme_secondary" {
  for_each = (var.sync_acme && module.config.replica_count > 1) ? toset([
    for i in range(1, module.config.replica_count) : "traefik-${i + 1}"
  ]) : []

  triggers = {
    instance_id     = module.ec2_secondary[0].instances[each.key].instance_id
    primary_ip      = local.primary_ip
    acme_primary_id = null_resource.wait_for_acme_primary[0].id
  }

  provisioner "local-exec" {
    command = <<-EOF
      PRIMARY_IP="${local.primary_ip}"
      SECONDARY_IP="${coalesce(module.ec2_secondary[0].public_ips[each.key], module.ec2_secondary[0].private_ips[each.key])}"

      export SSHPASS='topsecretpassword'
      SSH_OPTS="-o StrictHostKeyChecking=no -o PreferredAuthentications=password -o ConnectTimeout=10"

      echo "Syncing acme.json from $PRIMARY_IP to $SECONDARY_IP (${each.key})..."

      # Pull cert from primary
      sshpass -e ssh $SSH_OPTS traefiker@$PRIMARY_IP \
        "sudo cp /data/acme.json /home/traefiker/acme.json && sudo chown traefiker:traefiker /home/traefiker/acme.json"
      sshpass -e scp $SSH_OPTS traefiker@$PRIMARY_IP:/home/traefiker/acme.json ./acme-${each.key}.json
      sshpass -e ssh $SSH_OPTS traefiker@$PRIMARY_IP "rm /home/traefiker/acme.json"

      # Push cert to secondary and restart
      sshpass -e scp $SSH_OPTS ./acme-${each.key}.json traefiker@$SECONDARY_IP:/home/traefiker/acme.json
      sshpass -e ssh $SSH_OPTS traefiker@$SECONDARY_IP \
        "sudo mv /home/traefiker/acme.json /data/acme.json && sudo chown root:root /data/acme.json && sudo chmod 600 /data/acme.json && sudo systemctl restart traefik-hub"

      rm -f ./acme-${each.key}.json
      echo "Sync to $SECONDARY_IP (${each.key}) complete!"
    EOF
  }

  depends_on = [module.ec2_secondary]
}

# =============================================================================
# Shared Configuration Module - EC2
# =============================================================================
# EC2 uses extracted config from helm template (extract_config=true).
# Shared variables are defined here alongside the module instantiation.
# =============================================================================

module "config" {
  source = "../shared"

  # Extract config - EC2 needs CLI args, env vars from Helm template
  extract_config = true

  # Feature Flags
  enable_api_gateway    = var.enable_api_gateway
  enable_ai_gateway     = var.enable_ai_gateway
  enable_mcp_gateway    = var.enable_mcp_gateway
  enable_api_management = false # K8s only
  enable_offline_mode   = var.enable_offline_mode
  enable_preview_mode   = var.enable_preview_mode
  enable_debug          = var.enable_debug

  # Replica count
  replica_count = var.replica_count

  # Versions & Images
  traefik_chart_version   = var.traefik_chart_version
  traefik_tag             = var.traefik_tag
  traefik_hub_tag         = var.traefik_hub_tag
  traefik_hub_preview_tag = var.traefik_hub_preview_tag
  custom_image_registry   = var.custom_image_registry
  custom_image_repository = var.custom_image_repository
  custom_image_tag        = var.custom_image_tag

  # Observability
  log_level                    = var.log_level
  otlp_address                 = var.otlp_address
  otlp_service_name            = var.otlp_service_name
  enable_otlp_access_logs      = var.enable_otlp_access_logs
  enable_otlp_application_logs = var.enable_otlp_application_logs
  enable_otlp_metrics          = var.enable_otlp_metrics
  enable_otlp_traces           = var.enable_otlp_traces
  enable_prometheus            = var.enable_prometheus
  enable_access_logs           = var.enable_access_logs

  # Plugins & Extensions
  custom_plugins       = var.custom_plugins
  custom_ports         = var.custom_ports
  custom_arguments     = var.custom_arguments
  custom_envs          = var.custom_envs
  file_provider_config = var.file_provider_config
  file_provider_path   = var.file_provider_path

  # Licensing & DNS
  traefik_hub_token      = var.traefik_hub_token
  cloudflare_dns         = var.cloudflare_dns
  is_staging_letsencrypt = var.is_staging_letsencrypt

  # Dashboard
  enable_dashboard      = var.enable_dashboard
  dashboard_insecure    = var.dashboard_insecure
  dashboard_entrypoints = var.dashboard_entrypoints
  dashboard_match_rule  = var.dashboard_match_rule

  # Providers
  multicluster_provider = var.multicluster_provider
  nutanix_provider      = var.nutanix_provider
}
