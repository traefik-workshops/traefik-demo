resource "nutanix_virtual_machine" "vm" {
  name                 = var.name
  cluster_uuid         = var.cluster_uuid
  num_vcpus_per_socket = var.num_vcpus_per_socket
  num_sockets          = var.num_sockets
  memory_size_mib      = var.memory_size_mib

  nic_list {
    subnet_uuid = var.subnet_uuid
    dynamic "ip_endpoint_list" {
      for_each = var.static_ip != "" ? [var.static_ip] : []
      content {
        ip   = ip_endpoint_list.value
        type = "ASSIGNED"
      }
    }
  }

  disk_list {
    data_source_reference = {
      kind = "image"
      uuid = var.image_uuid
    }
    disk_size_mib = var.disk_size_mib
  }

  dynamic "categories" {
    for_each = var.categories
    content {
      name  = categories.key
      value = categories.value
    }
  }

  guest_customization_cloud_init_user_data = base64encode(var.cloud_init_user_data)
}
