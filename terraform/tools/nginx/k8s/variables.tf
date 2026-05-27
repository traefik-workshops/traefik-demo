variable "name" {
  description = "The name of the cert-manager release"
  type        = string
  default     = "cert-manager"
}

variable "namespace" {
  description = "Namespace for the cert-manager deployment"
  type        = string
}
