variable "cluster_name" {
  type        = string
  default     = "ai-demo"
  description = "Cluster name."
}

variable "cluster_location" {
  type        = string
  default     = "nyc1"
  description = "Cluster region/zone."
}

variable "domain" {
  type        = string
  description = "Base demo domain (e.g. ai.example.com)."
}

variable "traefik_hub_token" {
  type        = string
  sensitive   = true
  description = "Traefik Hub license token."
}

variable "demo_user_password" {
  type        = string
  sensitive   = true
  description = "Password for the seeded Keycloak demo user. Generate a fresh one per install — never reuse the demo default."
}
