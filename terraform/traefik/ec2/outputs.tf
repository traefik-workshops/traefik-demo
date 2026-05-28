output "instances" {
  description = "Map of EC2 instances with their details"
  value = merge(
    module.ec2_primary.instances,
    var.replica_count > 1 ? module.ec2_secondary[0].instances : {}
  )
}

output "public_ips" {
  description = "Map of instance names to their public IP addresses (Elastic IPs if created, otherwise instance public IPs)"
  value = merge(
    {
      for name, inst in module.ec2_primary.instances : name => (
        var.create_eip ? aws_eip.traefik[name].public_ip : inst.public_ip
      )
    },
    var.replica_count > 1 ? module.ec2_secondary[0].public_ips : {}
  )
}

output "private_ips" {
  description = "Map of instance names to their private IP addresses"
  value = merge(
    {
      for name, inst in module.ec2_primary.instances : name => inst.private_ip
    },
    var.replica_count > 1 ? module.ec2_secondary[0].private_ips : {}
  )
}
