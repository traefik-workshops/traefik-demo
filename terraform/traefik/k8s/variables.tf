# =============================================================================
# K8s-specific Variables
# =============================================================================
# Shared Traefik variables are defined in shared.tf.
# This file contains only K8s platform-specific variables.
# =============================================================================

variable "name" {
  description = "The name of the traefik release"
  type        = string
  default     = "traefik"
}

variable "namespace" {
  description = "Namespace for the Traefik Hub deployment"
  type        = string
}

variable "deploymentType" {
  description = "Traefik deployment type"
  type        = string
  default     = "Deployment"
}

variable "replicaCount" {
  description = "Number of replicas for the Traefik Hub deployment"
  type        = number
  default     = 1
}

variable "serviceType" {
  description = "Traefik service type"
  type        = string
  default     = "LoadBalancer"
}

variable "resources" {
  description = "Resources for the Traefik deployment. Set to null or leave empty strings to use chart defaults."
  type = object({
    requests = object({
      cpu    = string
      memory = string
    })
    limits = object({
      cpu    = string
      memory = string
    })
  })
  default = null
}

variable "tolerations" {
  description = "Tolerations for the Traefik deployment"
  type = list(object({
    key      = string
    operator = string
    value    = string
    effect   = string
  }))
  default = []
}

variable "redis_password" {
  description = "Redis password for API Management"
  type        = string
  default     = "topsecretpassword"
}

variable "skip_crds" {
  description = "Skip CRD installation (for NKP/Kommander clusters with pre-installed CRDs)"
  type        = bool
  default     = false
}

variable "skip_gateway_api_crds" {
  description = "Skip Gateway API CRD installation"
  type        = bool
  default     = false
}

variable "enable_knative_provider" {
  description = "Enable Knative provider"
  type        = bool
  default     = false
}

variable "custom_providers" {
  type        = any
  description = "Custom providers to use for the deployment"
  default     = {}
}

variable "custom_objects" {
  type        = list(object({}))
  description = "Extra Kubernetes objects to deploy"
  default     = []
}

variable "extra_values" {
  type        = any
  description = "Extra Helm values to merge"
  default     = {}
}

variable "kubernetes_namespaces" {
  description = "List of namespaces to watch for Kubernetes providers (Ingress, Gateway, CRD)"
  type        = list(string)
  default     = []
}

variable "service_annotations" {
  description = "Extra annotations for the Traefik service"
  type        = map(string)
  default     = {}
}

variable "ingress_class_name" {
  description = "The name of the ingress class"
  type        = string
  default     = "traefik"
}

variable "ingress_class_is_default" {
  description = "Whether this ingress class is the default"
  type        = bool
  default     = true
}

variable "external_traffic_policy" {
  description = "The external traffic policy for the Traefik service"
  type        = string
  default     = "Cluster"
}
