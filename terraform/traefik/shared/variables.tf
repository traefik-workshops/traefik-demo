# =============================================================================
# traefik/shared - Helm Template Extraction Module
# =============================================================================
# This module uses the Traefik K8s Helm chart as the source of truth.
# It renders the chart and extracts CLI arguments, environment variables,
# and configuration for use by VM-based deployments (EC2, ECS, Nutanix).
# =============================================================================

# -----------------------------------------------------------------------------
# Feature Flags
# -----------------------------------------------------------------------------

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
  description = "Enable Traefik Hub API Management features (K8s only)"
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

variable "replica_count" {
  description = "Number of replicas (VMs, EC2 instances, ECS tasks, K8s pods)"
  type        = number
  default     = 1
}

# -----------------------------------------------------------------------------
# Versions & Images
# -----------------------------------------------------------------------------

variable "traefik_chart_version" {
  description = "Traefik Helm chart version"
  type        = string
  default     = "38.0.1"
}

variable "traefik_tag" {
  description = "Traefik OSS version tag"
  type        = string
  default     = "v3.6.6"
}

variable "traefik_hub_tag" {
  description = "Traefik Hub version tag"
  type        = string
  default     = "v3.19.0"
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

# -----------------------------------------------------------------------------
# Observability
# -----------------------------------------------------------------------------

variable "log_level" {
  description = "Log level (DEBUG, INFO, WARN, ERROR)"
  type        = string
  default     = "INFO"
}

variable "enable_access_logs" {
  description = "Enable Traefik access logs"
  type        = bool
  default     = true
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

# -----------------------------------------------------------------------------
# Plugins & Extensions
# -----------------------------------------------------------------------------

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

variable "file_provider_config" {
  description = "YAML content for Traefik file provider dynamic configuration"
  type        = string
  default     = ""
}

variable "file_provider_path" {
  description = "Path where the file provider config is mounted (platform-specific)"
  type        = string
  default     = "/file-provider"
}

# -----------------------------------------------------------------------------
# Licensing & DNS
# -----------------------------------------------------------------------------

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
  default     = false
}

# -----------------------------------------------------------------------------
# Dashboard & Entry Points
# -----------------------------------------------------------------------------

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

variable "dashboard_entrypoints" {
  description = "Entrypoints for the Traefik dashboard"
  type        = list(string)
  default     = ["traefik"]
}

variable "dashboard_match_rule" {
  description = "Match rule for the Traefik dashboard router"
  type        = string
  default     = ""
}

variable "entry_points" {
  description = "Entry points configuration"
  type = map(object({
    address  = string
    port     = optional(number)
    protocol = optional(string, "TCP")
  }))
  default = {
    web = {
      address = ":80"
      port    = 80
    }
    websecure = {
      address = ":443"
      port    = 443
    }
    traefik = {
      address = ":8080"
      port    = 8080
    }
  }
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
    filename             = optional(string, "")
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
