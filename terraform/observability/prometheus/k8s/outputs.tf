output "service_endpoint" {
  description = "In-cluster Prometheus service URL (uses port 9090 by default)."
  value       = "http://${var.name}-server.${var.namespace}.svc.cluster.local"
}

output "namespace" {
  description = "Namespace the Prometheus release is installed into."
  value       = var.namespace
}
