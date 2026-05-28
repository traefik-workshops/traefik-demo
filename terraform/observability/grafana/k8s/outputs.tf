output "service_endpoint" {
  description = "In-cluster Grafana service URL."
  value       = "http://${var.name}.${var.namespace}.svc.cluster.local"
}

output "namespace" {
  description = "Namespace the Grafana release is installed into."
  value       = var.namespace
}
