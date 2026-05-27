resource "nutanix_floating_ip_v2" "vm_fip" {
  count = var.type == "VM" ? 1 : 0

  name                      = var.name
  external_subnet_reference = var.external_subnet_uuid

  association {
    vm_nic_association {
      vm_nic_reference = var.vm_nic_uuid
    }
  }

  lifecycle {
    precondition {
      condition     = var.private_ip == "" && var.vpc_uuid == ""
      error_message = "Conflicting configuration: vm_nic_uuid cannot be used with private_ip or vpc_uuid."
    }
  }
}

resource "nutanix_floating_ip_v2" "vpc_fip" {
  count = var.type == "VPC" ? 1 : 0

  name                      = var.name
  external_subnet_reference = var.external_subnet_uuid

  association {
    private_ip_association {
      vpc_reference = var.vpc_uuid
      private_ip {
        ipv4 {
          value = var.private_ip
        }
      }
    }
  }

  lifecycle {
    precondition {
      condition     = var.vm_nic_uuid == ""
      error_message = "Conflicting configuration: private_ip/vpc_uuid cannot be used with vm_nic_uuid."
    }
  }
}
