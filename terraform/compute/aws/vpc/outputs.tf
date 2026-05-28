output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "private_subnet_ids" {
  description = "Private subnets IDs"
  value       = module.vpc.private_subnets
}

output "public_subnet_ids" {
  description = "Public subnets IDs"
  value       = module.vpc.public_subnets
}

output "security_group_ids" {
  description = "Security group ID"
  value       = [aws_security_group.demo_sg.id]
}

output "private_route_table_ids" {
  description = "Private route table IDs"
  value       = module.vpc.private_route_table_ids
}

output "public_route_table_ids" {
  description = "Public route table IDs"
  value       = module.vpc.public_route_table_ids
}
