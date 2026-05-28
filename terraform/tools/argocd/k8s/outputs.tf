output "dashboard_url" {
  description = "URL of the ArgoCD dashboard. Reachable when var.ingress = true."
  value       = var.ingress ? "https://${var.name}.${var.ingress_domain}" : ""
}

output "admin_user" {
  description = "ArgoCD admin username (Helm chart default)."
  value       = "admin"
}

output "admin_password" {
  description = "ArgoCD admin password — same value as var.admin_password."
  value       = var.admin_password
  sensitive   = true
}

output "namespace" {
  description = "Namespace the ArgoCD release is installed into."
  value       = var.namespace
}
