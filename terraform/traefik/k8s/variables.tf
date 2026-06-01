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

variable "deployment_type" {
  description = "Traefik deployment type"
  type        = string
  default     = "Deployment"
}

variable "replica_count" {
  description = "Number of replicas for the Traefik Hub deployment"
  type        = number
  default     = 1
}

variable "service_type" {
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
  sensitive   = true
}

variable "skip_crds" {
  description = "Skip CRD installation (for NKP/Kommander clusters with pre-installed CRDs)"
  type        = bool
  default     = false
}

variable "kubeconfig" {
  description = "Path to a kubeconfig the CRD install (local-exec kubectl) should use. Empty = ambient kubeconfig / current context. Set this when the cluster is created in the same terraform run, so kubectl has no current context yet (e.g. demos that build a k3d cluster in-config)."
  type        = string
  default     = ""
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

# =============================================================================
# Shared Variable Declarations
# =============================================================================

# Feature Flags
variable "enable_api_gateway" {
  description = "Enable Traefik Hub API Gateway features"
  type        = bool
  default     = false
}

variable "enable_ai_gateway" {
  description = "Enable Traefik Hub AI Gateway features"
  type        = bool
  default     = false
}

variable "enable_mcp_gateway" {
  description = "Enable MCP Gateway (Claude, etc.)"
  type        = bool
  default     = false
}

variable "enable_api_management" {
  description = "Enable Traefik Hub API Management features"
  type        = bool
  default     = false
}

variable "enable_offline_mode" {
  description = "Enable Traefik Hub Offline mode"
  type        = bool
  default     = false
}

variable "enable_preview_mode" {
  description = "Enable Traefik Hub Preview features"
  type        = bool
  default     = false
}

variable "enable_debug" {
  description = "Enable Traefik debug mode (pprof)"
  type        = bool
  default     = false
}

# Versions & Images
variable "traefik_chart_version" {
  description = "Traefik Helm chart version (latest stable). Must render the partial metrics.otlp block this module sets: chart 38.x nil-pointers on .Values.metrics.otlp.resourceAttributes when that block is set without it; 40.x renders it."
  type        = string
  default     = "40.2.0"
}

variable "traefik_tag" {
  description = "Traefik OSS version tag"
  type        = string
  default     = "v3.6.6"
}

variable "traefik_hub_tag" {
  description = "Traefik Hub image tag for ghcr.io/traefik/traefik-hub (latest stable), paired with the default chart version above."
  type        = string
  default     = "v3.20.2"
}

variable "traefik_hub_preview_tag" {
  description = "Traefik Hub preview version tag"
  type        = string
  default     = ""
}

variable "custom_image_registry" {
  description = "Custom image registry"
  type        = string
  default     = ""
}

variable "custom_image_repository" {
  description = "Custom image repository"
  type        = string
  default     = ""
}

variable "custom_image_tag" {
  description = "Custom image tag"
  type        = string
  default     = ""
}

# Observability
variable "log_level" {
  description = "Log level (DEBUG, INFO, WARN, ERROR)"
  type        = string
  default     = "INFO"
}

variable "otlp_address" {
  description = "OTLP collector endpoint"
  type        = string
  default     = ""
}

variable "otlp_service_name" {
  description = "Service name for telemetry"
  type        = string
  default     = "traefik"
}

variable "enable_otlp_access_logs" {
  description = "Enable OTLP access logs"
  type        = bool
  default     = false
}

variable "enable_otlp_application_logs" {
  description = "Enable OTLP application logs"
  type        = bool
  default     = false
}

variable "enable_access_logs" {
  description = "Enable Traefik access logs"
  type        = bool
  default     = true
}

variable "enable_otlp_metrics" {
  description = "Enable OTLP metrics"
  type        = bool
  default     = false
}

variable "enable_otlp_traces" {
  description = "Enable OTLP traces"
  type        = bool
  default     = false
}

variable "enable_prometheus" {
  description = "Enable Prometheus metrics"
  type        = bool
  default     = false
}

# Plugins & Extensions
variable "custom_plugins" {
  description = "Custom plugins to use for the deployment"
  type = map(object({
    moduleName = string
    version    = string
  }))
  default = {}
}

variable "custom_ports" {
  description = "Custom ports configuration"
  type        = any
  default     = {}
}

variable "custom_arguments" {
  description = "Additional CLI arguments for Traefik"
  type        = list(string)
  default     = []
}

variable "custom_envs" {
  description = "Custom environment variables"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "additional_volumes" {
  description = "Additional volumes to mount in the Traefik pod"
  # `any`, not list(any): list(any) coerces mixed-type objects (e.g. a CSI volume
  # carrying a readOnly bool) to map(string), stringifying the bool.
  type    = any
  default = []
}

variable "additional_volume_mounts" {
  description = "Additional volume mounts for the Traefik container"
  # `any`, not list(any) — see additional_volumes above (readOnly bool coercion).
  type    = any
  default = []
}

variable "file_provider_config" {
  description = "YAML configuration for Traefik file provider"
  type        = string
  default     = ""
}

variable "file_provider_path" {
  description = "Path where the file provider config is mounted"
  type        = string
  default     = "/etc/traefik/dynamic"
}

# Licensing & DNS
variable "traefik_hub_token" {
  description = "Traefik Hub license token"
  type        = string
  default     = ""
  sensitive   = true
}

variable "cloudflare_dns" {
  description = "Cloudflare DNS configuration for certificate resolver"
  type = object({
    enabled           = optional(bool, false)
    domain            = optional(string, "")
    api_token         = optional(string, "")
    extra_san_domains = optional(list(string), [])
  })
  default = {
    enabled           = false
    domain            = ""
    api_token         = ""
    extra_san_domains = []
  }
  sensitive = true
}

variable "is_staging_letsencrypt" {
  description = "Use Let's Encrypt staging environment"
  type        = bool
  default     = false
}

variable "use_distributed_acme" {
  description = "Use distributedAcme instead of acme (stores certs in K8s secrets instead of acme.json file)"
  type        = bool
  default     = true
}

# Dashboard
variable "dashboard_entrypoints" {
  description = "Dashboard entry points"
  type        = list(string)
  default     = ["traefik"]
}

variable "dashboard_match_rule" {
  description = "Match rule for the Traefik dashboard router"
  type        = string
  default     = ""
}

variable "enable_dashboard" {
  description = "Enable Traefik dashboard"
  type        = bool
  default     = true
}

variable "dashboard_insecure" {
  description = "Enable insecure dashboard access (no auth)"
  type        = bool
  default     = false
}

# -----------------------------------------------------------------------------
# Providers
# -----------------------------------------------------------------------------
variable "multicluster_provider" {
  description = "Traefik Hub multicluster provider configuration"
  type = object({
    enabled      = optional(bool, false)
    pollInterval = optional(number, null)
    pollTimeout  = optional(number, null)
    children     = optional(any, {})
  })
  default = {
    enabled = false
  }
}

variable "nutanix_provider" {
  description = "Nutanix Prism Central provider configuration for VM discovery"
  type = object({
    enabled              = optional(bool, false)
    endpoint             = optional(string, "")
    username             = optional(string, "")
    password             = optional(string, "")
    api_key              = optional(string, "")
    insecure_skip_verify = optional(bool, false)
    poll_interval        = optional(string, "30s")
    poll_timeout         = optional(string, "5s")
  })
  default = {
    enabled = false
  }
  sensitive = true
}

variable "dns_traefiker" {
  description = "DNS Traefiker configuration for automatic domain registration"
  type = object({
    enabled                   = optional(bool, false)
    chart                     = optional(string, "")
    unique_domain             = optional(bool, false)
    domain                    = optional(string, "")
    enable_airlines_subdomain = optional(bool, false)
    ip_override               = optional(string, "")
    proxied                   = optional(bool, false)
  })
  default = {
    enabled = false
  }
}
