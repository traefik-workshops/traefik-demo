variable "name" {
  type        = string
  description = "The name of the grafana release"
  default     = "grafana"
}

variable "namespace" {
  type        = string
  description = "Namespace for the Grafana deployment"
}

variable "prometheus" {
  type = object({
    enabled = bool
    url = object({
      override  = string
      service   = string
      port      = number
      namespace = string
    })
  })
  description = "Prometheus datasource configuration."
}

variable "tempo" {
  type = object({
    enabled = bool
    url = object({
      override  = string
      service   = string
      port      = number
      namespace = string
    })
  })
  description = "Tempo datasource configuration."
}

variable "loki" {
  type = object({
    enabled = bool
    url = object({
      override  = string
      service   = string
      port      = number
      namespace = string
    })
  })
  description = "Loki datasource configuration."
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

variable "ingress" {
  type        = bool
  description = "Enable Ingress for the Grafana deployment."
  default     = false
}

variable "ingress_domain" {
  type        = string
  default     = "cloud"
  description = "The domain for the ingress, default is `cloud`"
}

variable "ingress_entrypoint" {
  type        = string
  default     = "traefik"
  description = "The entrypoint to use for the ingress, default is `traefik`"
}

variable "ingress_observability" {
  type        = bool
  description = "Emit Traefik observability signals (access logs, metrics, traces) for the Grafana ingress router. Set to false to add the three `traefik.ingress.kubernetes.io/router.observability.*: \"false\"` annotations. Same switch shape as other observability/k8s modules."
  default     = true
}

variable "ingress_annotations" {
  type        = map(string)
  description = "Additional metadata annotations merged onto the Ingress. Useful for custom router options beyond the three observability toggles."
  default     = {}
}

variable "dashboards" {
  type = object({
    aigateway  = bool
    mcpgateway = bool
    apim       = bool
  })
}

variable "extra_dashboards" {
  type        = map(string)
  description = "A map of dashboard names to their JSON content."
  default     = {}
}

variable "image_renderer" {
  type        = bool
  description = "Enable the Grafana Image Renderer plugin for PNG export of panels and dashboards."
  default     = false
}
