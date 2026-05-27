variable "name" {
  description = "The name of the ArgoCD release"
  type        = string
  default     = "argocd"
}

variable "namespace" {
  description = "Namespace for the ArgoCD deployment"
  type        = string
}

variable "admin_password" {
  description = "Admin password for ArgoCD"
  type        = string
  sensitive   = true
}

variable "ingress" {
  type        = bool
  description = "Enable Ingress for the ArgoCD deployment."
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
  description = "Emit Traefik observability signals (access logs, metrics, traces) for the ArgoCD ingress router. Set to false to add the three `traefik.ingress.kubernetes.io/router.observability.*: \"false\"` annotations. Same switch shape as other k8s modules."
  default     = true
}

variable "ingress_annotations" {
  type        = map(string)
  description = "Additional metadata annotations merged onto the Ingress. Useful for custom router options beyond the three observability toggles."
  default     = {}
}