variable "apps" {
  description = "Map of applications to deploy to Kubernetes. Each app can have multiple replicas."
  default     = {}
  type = map(object({
    replicas     = optional(number, 1)
    port         = optional(number, 80)
    docker_image = optional(string, "traefik/whoami:latest")
    labels       = optional(map(string), {})
    ingress_route = optional(object({
      enabled     = optional(bool, false)
      host        = optional(string)
      entrypoints = optional(list(string), ["web"])
      middlewares = optional(list(object({
        name      = string
        namespace = optional(string)
      })), [])
      strip_prefix = optional(object({
        enabled  = optional(bool, false)
        prefixes = optional(list(string), [])
      }), {})
    }), {})
  }))
}

variable "uplink_enabled" {
  description = "Enable Uplink CRD and IngressRoute annotation for multicluster routing"
  type        = bool
  default     = false
}

variable "namespace" {
  description = "Kubernetes namespace to deploy applications"
  type        = string
  default     = "apps"
}

variable "common_labels" {
  description = "Common labels to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "node_selector" {
  description = "Node selector for pod scheduling"
  type        = map(string)
  default     = {}
}

variable "ingress_observability" {
  type        = bool
  description = "Emit Traefik observability signals (access logs, metrics, traces) for every whoami IngressRoute this module creates. Set to false to add the three `traefik.ingress.kubernetes.io/router.observability.*: \"false\"` annotations. Same switch shape as other k8s modules."
  default     = true
}

variable "ingress_annotations" {
  type        = map(string)
  description = "Additional metadata annotations merged onto every whoami IngressRoute. Useful for custom router options beyond the three observability toggles."
  default     = {}
}
