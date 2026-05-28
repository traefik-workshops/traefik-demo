output "dashboard_url" {
  description = "URL of the MCP Inspector UI. Reachable when var.ingress = true."
  value       = var.ingress ? "https://${var.name}.${var.ingress_domain}" : ""
}

output "service_endpoint" {
  description = "In-cluster MCP Inspector service URL."
  value       = "http://${var.name}.${var.namespace}.svc.cluster.local"
}

output "namespace" {
  description = "Namespace the MCP Inspector release is installed into."
  value       = var.namespace
}
