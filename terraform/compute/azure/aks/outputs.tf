output "host" {
  description = "AKS cluster host"
  value       = azurerm_kubernetes_cluster.traefik_demo.kube_config.0.host
}

output "client_certificate" {
  description = "AKS cluster client certificate"
  value       = base64decode(azurerm_kubernetes_cluster.traefik_demo.kube_config.0.client_certificate)
}

output "client_key" {
  description = "AKS cluster client key"
  value       = base64decode(azurerm_kubernetes_cluster.traefik_demo.kube_config.0.client_key)
}

output "cluster_ca_certificate" {
  description = "AKS cluster CA certificate"
  value       = base64decode(azurerm_kubernetes_cluster.traefik_demo.kube_config.0.cluster_ca_certificate)
}
