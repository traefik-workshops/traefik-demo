output "vpc_uuid" {
  value = one(nutanix_vpc_v2.vpc[*].id)
}

output "subnet_uuids" {
  value = { for k, v in nutanix_subnet_v2.subnets : k => v.id }
}
