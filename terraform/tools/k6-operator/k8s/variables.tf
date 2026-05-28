variable "name" {
  description = "The name of the k6 release"
  type        = string
  default     = "k6-operator"
}

variable "namespace" {
  description = "Namespace for the k6 deployment"
  type        = string
}

variable "node_selector" {
  description = "Node selector for pod scheduling"
  type        = map(string)
  default     = {}
}

variable "tolerations" {
  description = "Tolerations for pod scheduling"
  type = list(object({
    key      = string
    operator = string
    value    = string
    effect   = string
  }))
  default = []
}

variable "extra_values" {
  description = "Extra values to merge into the Helm chart values"
  type        = any
  default     = {}
}
