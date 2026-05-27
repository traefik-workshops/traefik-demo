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

variable "metrics_host" {
  type        = string
  description = "Host of metrics endpoint"
  default     = ""
}

variable "metrics_port" {
  type        = number
  description = "Port of metrics endpoint"
  default     = 8889
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
  description = "Emit Traefik observability signals (access logs, metrics, traces) for the stack's Prometheus and Grafana ingress routers. Set to false to add the three `traefik.ingress.kubernetes.io/router.observability.*: \"false\"` annotations on each child module. Same switch shape as other observability/k8s modules."
  default     = true
}

variable "ingress_annotations" {
  type        = map(string)
  description = "Additional metadata annotations merged onto each child module's Ingress. Useful for custom router options beyond the three observability toggles."
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

variable "prometheus_extra_values" {
  type        = any
  description = "Extra values to pass to the Prometheus deployment."
  default     = {}
}

variable "grafana_extra_values" {
  type        = any
  description = "Extra values to pass to the Grafana deployment."
  default     = {}
}

variable "prometheus_url_override" {
  type        = string
  default     = ""
  description = "If non-empty, Grafana's Prometheus datasource URL is set to this value instead of the default kube-prometheus-stack service. Useful when you route queries through a Prom-compatible backend like VictoriaMetrics vmselect."
}
