output "running_from_source" {
  description = "Whether this apply wired the locally-built Hub image."
  value       = var.local_traefik_hub
}

output "hub_image" {
  description = "The Traefik Hub image the module was told to run. Empty registry/repo/tag means the module's released default."
  value       = var.local_traefik_hub ? "${local.hub_image_registry}/${local.hub_image_repository}:${local.hub_image_tag}" : "(module default released image)"
}

output "dashboard_url" {
  description = "Traefik dashboard URL (k3d maps 443 to localhost; curl with -k)."
  value       = "https://dashboard.${var.domain}"
}

output "whoami_url" {
  description = "Sample workload URL — returns whoami JSON once Traefik is ready."
  value       = "https://whoami.${var.domain}"
}
