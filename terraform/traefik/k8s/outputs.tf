output "load_balancer_ip" {
  description = "The Load Balancer IP of the Traefik Service"
  value       = try(data.kubernetes_service_v1.traefik.status.0.load_balancer.0.ingress.0.ip, "")
}

output "domain" {
  description = "The computed domain for Traefik"
  value       = var.dns_traefiker.enabled && length(data.kubernetes_secret_v1.dns_domain) > 0 ? data.kubernetes_secret_v1.dns_domain[0].data.domain : var.cloudflare_dns.domain
}

output "dashboard_url" {
  description = "The Traefik dashboard URL"
  value       = "https://dashboard.${var.dns_traefiker.enabled && length(data.kubernetes_secret_v1.dns_domain) > 0 ? data.kubernetes_secret_v1.dns_domain[0].data.domain : var.cloudflare_dns.domain}"
}

data "kubernetes_service_v1" "traefik" {
  metadata {
    name      = var.name
    namespace = var.namespace
  }

  depends_on = [helm_release.traefik]
}
