output "vpc_uuid" {
  description = "Vpc uuid."
  value = one(nutanix_vpc_v2.vpc[*].id)
}

output "subnet_uuids" {
  description = "Subnet uuids."
  value = { for k, v in nutanix_subnet_v2.subnets : k => v.id }
}
