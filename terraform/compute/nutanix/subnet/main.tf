resource "nutanix_subnet_v2" "this" {
  name              = var.name
  description       = var.description
  cluster_reference = var.cluster_id
  subnet_type       = "VLAN"
  network_id        = var.vlan_id
  is_external       = var.is_external

  ip_config {
    ipv4 {
      ip_subnet {
        ip {
          value = cidrhost(var.subnet_cidr, 0)
        }
        prefix_length = tonumber(split("/", var.subnet_cidr)[1])
      }
      default_gateway_ip {
        value = var.gateway_ip
      }
      pool_list {
        start_ip {
          value = cidrhost(var.subnet_cidr, 4)
        }
        end_ip {
          value = cidrhost(var.subnet_cidr, -2)
        }
      }
    }
  }

  dynamic "dhcp_options" {
    for_each = var.is_external ? [] : [1]
    content {
      domain_name_servers {
        dynamic "ipv4" {
          for_each = var.dns_nameservers
          content {
            value         = ipv4.value
            prefix_length = 32
          }
        }
      }
    }
  }
}
