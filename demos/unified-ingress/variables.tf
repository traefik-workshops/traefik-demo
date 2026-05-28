variable "cluster_prefix" {
  type        = string
  description = "Prefix for the two cluster names (e.g. \"acme\" -> acme-transit + acme-app)."
  default     = "unified-ingress"
}

variable "domain" {
  type        = string
  description = "Base demo domain. With k3d this resolves to localhost, so any *.localhost works (dashboard at dashboard.<domain>, whoami at whoami.<domain>)."
  default     = "unified-ingress.localhost"
}

variable "traefik_hub_token" {
  type        = string
  description = "Traefik Hub license token (offline JWT), shared by both clusters. Get one at https://hub.traefik.io."
  sensitive   = true
}
