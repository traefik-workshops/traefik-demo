variable "name" {
  type        = string
  description = "The name of the knative release"
  default     = "knative"
}

variable "namespace" {
  type        = string
  description = "The namespace of the knative release"
}

variable "ingress_domain" {
  type        = string
  description = "The external domain where knative will publish services."
  default     = "demo.traefik.ai"
}
