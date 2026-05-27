variable "name" {
  description = "The name of the traefik release"
  type        = string
  default     = "traefik"
}

variable "namespace" {
  description = "Namespace for the Traefik Hub deployment"
  type        = string
}


variable "password" {
  description = "Redis password"
  type        = string
  default     = "topsecretpassword"
}

variable "database" {
  description = "Database name"
  type        = string
  default     = "postgres"
}

variable "extra_values" {
  description = "Extra values to merge into the Helm chart values"
  type        = any
  default     = {}
}
