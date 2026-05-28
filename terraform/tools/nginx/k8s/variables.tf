variable "name" {
  description = "Name of the NGINX ingress controller Helm release."
  type        = string
  default     = "nginx"
}

variable "namespace" {
  description = "Namespace for the NGINX deployment."
  type        = string
}
