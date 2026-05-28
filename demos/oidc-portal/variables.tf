variable "cluster_name" {
  type    = string
  default = "oidc-portal-demo"
}
variable "region" {
  type    = string
  default = "us-east-1"
}
variable "domain" {
  type        = string
  description = "Base demo domain. Portal at portal.<domain>."
}
variable "traefik_hub_token" {
  type      = string
  sensitive = true
}
