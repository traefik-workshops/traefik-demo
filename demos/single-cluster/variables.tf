variable "cluster_name" {
  type        = string
  description = "k3d cluster name."
  default     = "single-cluster"
}

variable "domain" {
  type        = string
  description = "Domain the whoami ingress is exposed on. With k3d this resolves to localhost, so any *.localhost works."
  default     = "single-cluster.localhost"
}

variable "traefik_hub_token" {
  type        = string
  description = "Traefik Hub license token (offline JWT). Get one at https://hub.traefik.io."
  sensitive   = true
}
