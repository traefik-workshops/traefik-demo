locals {
  kubeconfig_raw  = data.oci_containerengine_cluster_kube_config.kubeconfig.content
  kubeconfig      = yamldecode(local.kubeconfig_raw)
  cluster         = local.kubeconfig.clusters[0].cluster
  cluster_server  = local.cluster.server
  cluster_ca_cert = base64decode(local.cluster["certificate-authority-data"])
  token           = data.external.cluster_token.result.token
}

output "host" {
  sensitive   = true
  description = "OKE cluster host"
  value       = local.cluster_server
}

output "cluster_ca_certificate" {
  sensitive   = true
  description = "OKE cluster CA certificate"
  value       = local.cluster_ca_cert
}

output "token" {
  sensitive   = true
  description = "OKE cluster auth token"
  value       = local.token
}

output "kubeconfig" {
  sensitive   = true
  description = "OKE cluster kubeconfig"
  value       = local.kubeconfig_raw
}

output "cluster_id" {
  sensitive   = true
  description = "OKE cluster ID"
  value       = oci_containerengine_cluster.traefik_demo.id
}

output "node_pool_id" {
  sensitive   = true
  description = "OKE node pool ID"
  value       = length(oci_containerengine_node_pool.traefik_demo) > 0 ? oci_containerengine_node_pool.traefik_demo[0].id : null
}
