variable "cluster_prefix" {
  type        = string
  description = "Prefix for cluster names (e.g. \"acme\" produces acme-transit + acme-app)."
  default     = "demo"
}

variable "cluster_location" {
  type        = string
  description = "Region/zone for both clusters."
  default     = "nyc1"
}

variable "domain" {
  type        = string
  description = "Base demo domain (Traefik dashboard at dashboard.<domain>)."
}

variable "traefik_hub_token" {
  type        = string
  description = "Traefik Hub license token (single token shared by both clusters)."
  sensitive   = true
}
