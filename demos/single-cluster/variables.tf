variable "cluster_name" {
  type        = string
  description = "Name for the demo cluster."
  default     = "demo"
}

variable "cluster_location" {
  type        = string
  description = "Cluster region/zone. Cheapest by default."
  default     = "nyc1"
}

variable "domain" {
  type        = string
  description = "Domain to expose the whoami ingress on (e.g. demo.example.com)."
}

variable "traefik_hub_token" {
  type        = string
  description = "Traefik Hub license token."
  sensitive   = true
}
