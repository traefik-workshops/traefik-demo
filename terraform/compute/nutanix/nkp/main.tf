locals {
  bastion_vm_ip       = nutanix_floating_ip_v2.bastion_fip.floating_ip[0].ipv4[0].value
  cluster_subnets_str = join(",", var.cluster_subnets)

  bastion_vm_cloud_init = templatefile("${path.module}/templates/cloud-init.tpl", {
    hostname             = "${var.cluster_name}-nkp-bastion"
    bastion_vm_username  = var.bastion_vm_username
    bastion_vm_password  = var.bastion_vm_password
    registry_mirror_url  = var.registry_mirror_url
    registry_host        = var.registry_mirror_url != "" ? split("/", split("//", var.registry_mirror_url)[1])[0] : ""
    registry_mirror_full = var.registry_mirror_url
  })


  traefik_ip  = var.lb_ip_range != "" ? split("-", var.lb_ip_range)[0] : ""
  traefik_fip = var.enable_kommander_traefik_fip ? nutanix_floating_ip_v2.lb_fip[0].floating_ip[0].ipv4[0].value : ""

  control_plane_fip = var.control_plane_fip
  cluster_hostnames = local.traefik_fip
}

resource "nutanix_floating_ip_v2" "lb_fip" {
  count                     = var.enable_kommander_traefik_fip ? 1 : 0
  name                      = "${var.cluster_name}-lb-fip"
  external_subnet_reference = var.external_subnet_uuid
  association {
    private_ip_association {
      vpc_reference = var.vpc_uuid
      private_ip {
        ipv4 {
          value = local.traefik_ip
        }
      }
    }
  }
}

resource "nutanix_virtual_machine" "bastion_vm" {
  name                 = "${var.cluster_name}-bastion"
  cluster_uuid         = var.nutanix_cluster_id
  num_vcpus_per_socket = 8
  num_sockets          = 1
  memory_size_mib      = 16 * 1024
  disk_list {
    data_source_reference = {
      kind = "image"
      uuid = var.nkp_image_uuid
    }
    device_properties {
      device_type = "DISK"
      disk_address = {
        device_index = 0
        adapter_type = "SCSI"
      }
    }
    disk_size_bytes = 131072 * 1024 * 1024
  }
  guest_customization_cloud_init_user_data = base64encode(local.bastion_vm_cloud_init)
  nic_list {
    subnet_uuid = var.bastion_subnet_uuid
  }
}

resource "nutanix_floating_ip_v2" "bastion_fip" {
  name                      = "${var.cluster_name}-bastion-fip"
  external_subnet_reference = var.external_subnet_uuid

  association {
    vm_nic_association {
      vm_nic_reference = nutanix_virtual_machine.bastion_vm.nic_list[0].uuid
    }
  }

  depends_on = [
    nutanix_virtual_machine.bastion_vm
  ]
}

resource "null_resource" "nkp_create_cluster" {
  triggers = {
    bastion_vm_id       = nutanix_virtual_machine.bastion_vm.metadata.uuid
    bastion_vm_ip       = local.bastion_vm_ip
    bastion_vm_username = var.bastion_vm_username
    bastion_vm_password = nonsensitive(var.bastion_vm_password)
    cluster_name        = var.cluster_name
    control_plane_vip   = var.control_plane_vip
    lb_ip_range         = var.lb_ip_range
    create_script_hash  = filesha256("${path.module}/scripts/nkp_create_cluster.sh")
    delete_script_hash  = filesha256("${path.module}/scripts/cleanup_nutanix_resources.py")
    nutanix_endpoint    = var.nutanix_endpoint
    nutanix_port        = var.nutanix_port
    nutanix_username    = var.nutanix_username
    nutanix_password    = nonsensitive(var.nutanix_password)
    storage_container   = var.storage_container
    cluster_hostnames   = local.traefik_fip
  }

  connection {
    type     = "ssh"
    user     = self.triggers.bastion_vm_username
    password = self.triggers.bastion_vm_password
    host     = self.triggers.bastion_vm_ip
  }

  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait || (echo '--- daemon.json ---'; cat /etc/docker/daemon.json; echo '--- journalctl ---'; journalctl -xeu docker.service --no-pager; exit 1)"
    ]
  }

  provisioner "file" {
    destination = "variables.sh"
    content     = <<-EOF
    export NUTANIX_USER="${var.nutanix_username}"
    export NUTANIX_PASSWORD="${nonsensitive(var.nutanix_password)}"
    export NUTANIX_ENDPOINT="${var.nutanix_endpoint}"
    export NUTANIX_PORT="${var.nutanix_port}"
    export NUTANIX_INSECURE="${var.nutanix_insecure}"
    export NUTANIX_PRISM_ELEMENT_CLUSTER_NAME="${var.nutanix_prism_element_cluster_name}"
    export NUTANIX_SUBNETS="${join(",", var.cluster_subnets)}"
    export NUTANIX_CLUSTER_NAME="${var.cluster_name}"
    export CLUSTER_NAME="${var.cluster_name}"
    export NUTANIX_MACHINE_TEMPLATE_IMAGE_NAME="${var.nkp_image_name}"
    export NUTANIX_STORAGE_CONTAINER_NAME="${var.storage_container}"
    export CONTROL_PLANE_ENDPOINT_IP="${var.control_plane_vip}"
    export LB_IP_RANGE="${var.lb_ip_range}"
    export NKP_VERSION="${var.nkp_version}"
    export REGISTRY_MIRROR_URL="${var.registry_mirror_url}"
    export BASTION_IMAGE_NAME="${var.bastion_image_name}"
    export CP_REPLICAS="${var.control_plane_replicas}"
    export WORKER_REPLICAS="${var.worker_replicas}"
    export CP_MEM="${var.control_plane_memory_mib}"
    export CP_CPU="${var.control_plane_vcpus}"
    export WORKER_MEM="${var.worker_memory_mib}"
    export WORKER_CPU="${var.worker_vcpus}"
    export KUBERNETES_VERSION="${var.kubernetes_version}"
    export CLUSTER_HOSTNAMES="${local.traefik_fip}"
    EOF
  }

  # NKP cluster creation
  provisioner "remote-exec" {
    script = "${path.module}/scripts/nkp_create_cluster.sh"
  }

  provisioner "file" {
    source      = "${path.module}/scripts/cleanup_nutanix_resources.py"
    destination = "cleanup_nutanix_resources.py"
  }

  provisioner "remote-exec" {
    when = destroy
    inline = [
      "python3 -m pip install 'ntnx-vmm-py-client<4.2' 'ntnx-volumes-py-client<4.2' requests --quiet --break-system-packages",
      "NUTANIX_ENDPOINT=${self.triggers.nutanix_endpoint} NUTANIX_PORT=${self.triggers.nutanix_port} NUTANIX_USERNAME=${self.triggers.nutanix_username} NUTANIX_PASSWORD=${nonsensitive(self.triggers.nutanix_password)} python3 cleanup_nutanix_resources.py --vm-pattern '^(?!.*-bastion$).*${self.triggers.cluster_name}.*' --storage-container ${self.triggers.storage_container}"
    ]
  }

  depends_on = [nutanix_floating_ip_v2.bastion_fip]
}
