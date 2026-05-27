output "dashboard_url" {
  description = "Traefik dashboard URL."
  value       = "https://dashboard.${var.domain}"
}

output "keycloak_url" {
  description = "Keycloak admin console."
  value       = "https://keycloak.${var.domain}"
}

output "ai_gateway_install_command" {
  description = "Helm command to install the AI gateway chart on top of this stack."
  value = <<-EOT
    helm install ai-gateway oci://ghcr.io/traefik-workshops/ai-gateway --version 4.0.0 \
      --namespace ${kubernetes_namespace_v1.ai.metadata[0].name} \
      --set domain=${var.domain} \
      --set apiKeys.openai="$$OPENAI_API_KEY"
  EOT
}
