locals {
  kubeconfig_raw  = digitalocean_kubernetes_cluster.traefik_demo.kube_config.0.raw_config
  kubeconfig      = yamldecode(local.kubeconfig_raw)
  cluster         = local.kubeconfig.clusters[0].cluster
  cluster_server  = local.cluster.server
  cluster_ca_cert = base64decode(local.cluster["certificate-authority-data"])
  token           = local.kubeconfig.users[0].user.token
}


output "host" {
  sensitive   = true
  description = "DOKS cluster host"
  value       = local.cluster_server
}

output "cluster_ca_certificate" {
  sensitive   = true
  description = "DOKS cluster CA certificate"
  value       = local.cluster_ca_cert
}

output "token" {
  sensitive   = true
  description = "DOKS cluster auth token"
  value       = local.token
}

output "kubeconfig" {
  sensitive   = true
  description = "DOKS cluster kubeconfig"
  value       = local.kubeconfig_raw
}

output "cluster_id" {
  sensitive   = true
  description = "DOKS cluster ID"
  value       = digitalocean_kubernetes_cluster.traefik_demo.id
}

output "cluster_name" {
  description = "DOKS cluster name"
  value       = digitalocean_kubernetes_cluster.traefik_demo.name
}

output "endpoint" {
  description = "DOKS cluster endpoint"
  value       = digitalocean_kubernetes_cluster.traefik_demo.endpoint
}

output "region" {
  description = "DOKS cluster region"
  value       = digitalocean_kubernetes_cluster.traefik_demo.region
}

output "version" {
  description = "DOKS cluster Kubernetes version"
  value       = digitalocean_kubernetes_cluster.traefik_demo.version
}