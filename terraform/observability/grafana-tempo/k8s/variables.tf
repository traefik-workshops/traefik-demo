variable "name" {
  type        = string
  description = "The name of the tempo release"
  default     = "tempo"
}

variable "namespace" {
  type        = string
  description = "Namespace for the Grafana deployment"
}

variable "tolerations" {
  type = list(object({
    key      = string
    operator = string
    value    = string
    effect   = string
  }))
  description = "Tolerations for the Grafana deployment."
  default     = []
}

variable "extra_values" {
  type        = any
  description = "Extra values to pass to the Grafana deployment."
  default     = {}
}
