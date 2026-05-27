resource "nutanix_vpc_v2" "vpc" {
  name     = var.vpc_name
  vpc_type = var.vpc_type

  dynamic "externally_routable_prefixes" {
    for_each = var.externally_routable_prefixes
    content {
      ipv4 {
        ip {
          value         = split("/", externally_routable_prefixes.value)[0]
          prefix_length = 32
        }
        prefix_length = tonumber(split("/", externally_routable_prefixes.value)[1])
      }
    }
  }

  external_subnets {
    subnet_reference = var.external_subnet_uuid
  }

  lifecycle {
    ignore_changes = [external_subnets[0].active_gateway_node]
  }
}

resource "nutanix_subnet_v2" "subnets" {
  for_each = var.subnets

  name          = each.key
  subnet_type   = "OVERLAY"
  vpc_reference = nutanix_vpc_v2.vpc.id

  ip_config {
    ipv4 {
      ip_subnet {
        ip {
          value = cidrhost(each.value.cidr, 0)
        }
        prefix_length = each.value.prefix_length != null ? each.value.prefix_length : tonumber(split("/", each.value.cidr)[1])
      }
      default_gateway_ip {
        value = cidrhost(each.value.cidr, 1)
      }
      pool_list {
        start_ip {
          value = cidrhost(each.value.cidr, 10)
        }
        end_ip {
          value = cidrhost(each.value.cidr, 250)
        }
      }
    }
  }

  dhcp_options {
    domain_name_servers {
      dynamic "ipv4" {
        for_each = var.dns_servers
        content {
          value         = ipv4.value
          prefix_length = 32
        }
      }
    }
  }

  lifecycle {
    ignore_changes = [dhcp_options]
  }
}

resource "nutanix_static_routes" "external_reroute" {
  vpc_name = nutanix_vpc_v2.vpc.name
  default_route_nexthop {
    external_subnet_reference_uuid = var.external_subnet_uuid
  }
}
