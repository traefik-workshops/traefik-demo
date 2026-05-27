locals {
  # Build category map for service discovery using hardcoded default keys
  service_categories = var.service_name != "" ? merge(
    {
      "TraefikServiceName" = var.service_name
      "TraefikServicePort" = tostring(var.service_port)
    },
    var.load_balancer_strategy != "" ? {
      "TraefikLoadBalancerStrategy" = var.load_balancer_strategy
    } : {}
  ) : {}
}

# Use shared cloud-init module
module "cloud_init" {
  source = "../cloud-init"

  whoami_version = var.whoami_version
  arch           = var.arch
  port           = var.service_port
}

module "whoami_vm" {
  source = "../../../compute/nutanix/vm"

  name                 = var.vm_name
  cluster_uuid         = var.cluster_id
  subnet_uuid          = var.subnet_uuid
  image_uuid           = var.image_id
  num_vcpus_per_socket = var.vm_num_vcpus_per_socket
  num_sockets          = var.vm_num_sockets
  memory_size_mib      = var.vm_memory_mib

  # Apply service discovery categories
  categories = local.service_categories

  cloud_init_user_data = module.cloud_init.rendered
}

output "ip_address" {
  value = module.whoami_vm.ip_address
}
