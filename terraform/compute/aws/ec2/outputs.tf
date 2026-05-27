output "instances" {
  description = "Map of all instances with their details"
  value = {
    for key, instance in aws_instance.ec2 : key => {
      instance_id = instance.id
      app_name    = local.instances_map[key].app_name
      replica     = local.instances_map[key].replica_number
      private_ip  = instance.private_ip
      public_ip   = instance.public_ip
      public_dns  = instance.public_dns
      subnet_ids  = local.instances_map[key].subnet_ids
      arn         = instance.arn
    }
  }
}

output "private_ips" {
  description = "Map of instance keys to private IP addresses"
  value = {
    for key, instance in aws_instance.ec2 : key => instance.private_ip
  }
}

output "public_ips" {
  description = "Map of instance keys to public IP addresses"
  value = {
    for key, instance in aws_instance.ec2 : key => instance.public_ip
  }
}
