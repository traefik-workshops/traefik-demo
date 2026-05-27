output "host" {
  description = "k3d cluster host"
  value       = k3d_cluster.traefik_demo.host
}

output "client_certificate" {
  description = "k3d cluster client certificate"
  value       = base64decode(k3d_cluster.traefik_demo.client_certificate)
}

output "client_key" {
  description = "k3d cluster client key"
  value       = base64decode(k3d_cluster.traefik_demo.client_key)
}

output "cluster_ca_certificate" {
  description = "k3d cluster CA certificate"
  value       = base64decode(k3d_cluster.traefik_demo.cluster_ca_certificate)
}
