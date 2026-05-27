
variable "name" {
  type        = string
  description = "The name of the prometheus release"
  default     = "prometheus"
}

variable "namespace" {
  type        = string
  description = "Namespace for the Prometheus deployment"
}

variable "traefik_metrics_job_url" {
  type        = string
  description = "URL for the Traefik metrics job"
  default     = ""
}

variable "traefik_metrics_job_metrics_path" {
  type        = string
  description = "Metrics path for the Traefik metrics job"
  default     = "/metrics"
}

variable "tolerations" {
  type = list(object({
    key      = string
    operator = string
    value    = string
    effect   = string
  }))
  description = "Tolerations for the Prometheus deployment."
  default     = []
}

variable "extra_values" {
  type        = any
  description = "Extra values to pass to the Prometheus deployment."
  default     = {}
}

variable "ingress" {
  type        = bool
  description = "Enable Ingress for the Prometheus deployment."
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
  description = "Emit Traefik observability signals (access logs, metrics, traces) for the Prometheus ingress router. Set to false to add the three `traefik.ingress.kubernetes.io/router.observability.*: \"false\"` annotations. Same switch shape as other observability/k8s modules."
  default     = true
}

variable "ingress_annotations" {
  type        = map(string)
  description = "Additional metadata annotations merged onto the Ingress. Useful for custom router options beyond the three observability toggles."
  default     = {}
}
