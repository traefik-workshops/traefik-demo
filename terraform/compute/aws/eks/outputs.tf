data "aws_eks_cluster_auth" "eks" {
  name = var.cluster_name
}

output "cluster_endpoint" {
  description = "EKS cluster host"
  value       = module.eks.cluster_endpoint
}

output "cluster_ca_certificate" {
  sensitive   = true
  description = "EKS cluster CA certificate"
  value       = base64decode(module.eks.cluster_certificate_authority_data)
}

output "token" {
  sensitive   = true
  description = "EKS cluster auth token"
  value       = data.aws_eks_cluster_auth.eks.token
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = module.eks.cluster_security_group_id
}

output "node_security_group_id" {
  description = "Security group ID attached to the EKS worker nodes"
  value       = module.eks.node_security_group_id
}
