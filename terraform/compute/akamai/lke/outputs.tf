locals {
  kubeconfig_raw  = base64decode(linode_lke_cluster.traefik_demo.kubeconfig)
  kubeconfig      = yamldecode(local.kubeconfig_raw)
  cluster         = local.kubeconfig.clusters[0].cluster
  cluster_server  = local.cluster.server
  cluster_ca_cert = base64decode(local.cluster["certificate-authority-data"])
  token           = local.kubeconfig.users[0].user.token
}

output "host" {
  sensitive   = true
  description = "LKE cluster host"
  value       = local.cluster_server
}

output "cluster_ca_certificate" {
  sensitive   = true
  description = "LKE cluster CA certificate"
  value       = local.cluster_ca_cert
}

output "token" {
  sensitive   = true
  description = "LKE cluster auth token"
  value       = local.token
}

output "kubeconfig" {
  sensitive   = true
  description = "LKE cluster kubeconfig"
  value       = local.kubeconfig_raw
}

output "cluster_id" {
  sensitive   = true
  description = "LKE cluster ID"
  value       = linode_lke_cluster.traefik_demo.id
}
