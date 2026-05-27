resource "nutanix_virtual_machine" "registry_vm" {
  name                 = "${var.cluster_name}-registry"
  cluster_uuid         = var.nutanix_cluster_id
  num_vcpus_per_socket = 32
  num_sockets          = 1
  memory_size_mib      = 65536

  nic_list {
    subnet_uuid = var.subnet_uuid
    ip_endpoint_list {
      ip   = var.private_ip
      type = "ASSIGNED"
    }
  }

  disk_list {
    data_source_reference = {
      kind = "image"
      uuid = var.registry_image_uuid
    }

    # 200GB for bundle and extracted images
    disk_size_mib = 204800
  }

  guest_customization_cloud_init_user_data = base64encode(<<EOF
#cloud-config
hostname: ${var.cluster_name}-registry
users:
  - name: ubuntu
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    ssh-authorized-keys:
      - ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHT/Lz35y0Fq1qL40D9gH5sX+n54n55P55r55t55v55x nkp-registry
EOF
  )
}
resource "terraform_data" "registry_health_check" {
  input = var.public_ip != null ? var.public_ip : nutanix_virtual_machine.registry_vm.nic_list[0].ip_endpoint_list[0].ip

  provisioner "file" {
    connection {
      type     = "ssh"
      user     = "traefiker"
      password = "topsecretpassword"
      host     = self.input
      timeout  = "10m"
    }
    source      = "${path.module}/../registry_image/packer/scripts/setup_registry_runtime.sh"
    destination = "/tmp/setup_registry_runtime.sh"
  }

  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      user     = "traefiker"
      password = "topsecretpassword"
      host     = self.input
      timeout  = "40m"
    }
    inline = [
      "sudo mv /tmp/setup_registry_runtime.sh /usr/local/bin/setup_registry_runtime.sh",
      "sudo chmod +x /usr/local/bin/setup_registry_runtime.sh",
      "sudo DOCKER_HUB_USERNAME='${var.docker_hub_username}' DOCKER_HUB_ACCESS_TOKEN='${nonsensitive(var.docker_hub_access_token)}' /usr/local/bin/setup_registry_runtime.sh",
      "# Final health check to ensure registry is serving images",
      "for i in {1..30}; do",
      "  if curl -s http://localhost:5000/v2/ >/dev/null; then",
      "    echo 'Registry is up and serving images.'",
      "    exit 0",
      "  fi",
      "  echo 'Waiting for registry...'",
      "  sleep 10",
      "done",
      "exit 1"
    ]
  }

  depends_on = [nutanix_virtual_machine.registry_vm]
}
