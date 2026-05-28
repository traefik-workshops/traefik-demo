# =============================================================================
# EC2-specific Variables
# =============================================================================
# Shared Traefik variables are defined in shared.tf.
# This file contains only EC2 platform-specific variables.
# =============================================================================

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small"
}

variable "ami_architecture" {
  description = "AMI architecture (x86_64 or arm64)"
  type        = string
  default     = "x86_64"
}

variable "create_vpc" {
  description = "Create VPC if vpc_id is not provided"
  type        = bool
  default     = true
}

variable "vpc_id" {
  description = "VPC ID for EC2 instances"
  type        = string
  default     = ""

  validation {
    condition     = var.create_vpc || var.vpc_id != ""
    error_message = "vpc_id must be provided if create_vpc is false"
  }
}

variable "subnet_ids" {
  description = "List of subnet IDs for EC2 instances"
  type        = list(string)
  default     = []

  validation {
    condition     = var.create_vpc || length(var.subnet_ids) > 0
    error_message = "subnet_ids must be provided if create_vpc is false"
  }
}

variable "security_group_ids" {
  description = "List of security group IDs for EC2 instances"
  type        = list(string)
  default     = []

  validation {
    condition     = var.create_vpc || length(var.security_group_ids) > 0
    error_message = "security_group_ids must be provided if create_vpc is false"
  }
}

variable "iam_instance_profile" {
  description = "IAM instance profile name to attach to EC2 instances"
  type        = string
  default     = ""
}

variable "extra_tags" {
  description = "Extra tags to apply to EC2 instances"
  type        = map(string)
  default     = {}
}

variable "root_block_device_size" {
  description = "Root block device size in GB"
  type        = number
  default     = 30
}

# =============================================================================
# Performance Tuning Configuration
# =============================================================================

variable "performance_tuning" {
  description = "OS-level performance tuning parameters for high-throughput workloads"
  type = object({
    # Systemd ulimits
    limit_nofile = optional(number, 500000)

    # Sysctl network tuning
    tcp_tw_reuse        = optional(number, 1)
    tcp_timestamps      = optional(number, 1)
    rmem_max            = optional(number, 16777216)
    wmem_max            = optional(number, 16777216)
    somaxconn           = optional(number, 4096)
    netdev_max_backlog  = optional(number, 4096)
    ip_local_port_range = optional(string, "1024 65535")

    # Go runtime tuning
    gomaxprocs = optional(number, 0)   # 0 = use all CPUs
    gogc       = optional(number, 100) # default GC target percentage
    numa_node  = optional(number, -1)  # -1 = disabled, 0+ = pin to node
  })
  default = {}
}

variable "wait_for_ready" {
  description = "Wait for Traefik to be ready (responding on port 80) before completing"
  type        = bool
  default     = true
}

variable "wait_timeout" {
  description = "Timeout in seconds to wait for Traefik readiness"
  type        = number
  default     = 300
}

variable "create_eip" {
  description = "Create and attach an Elastic IP to the first Traefik instance"
  type        = bool
  default     = false
}

variable "sync_acme" {
  description = "Synchronize acme.json from the first instance to all others"
  type        = bool
  default     = false
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
  description = "Number of replicas (EC2 instances)"
  type        = number
  default     = 1
}

# Versions & Images
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
  type = map(object({
    port     = number
    protocol = optional(string, "tcp")
  }))
  default = {}
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
  description = "YAML configuration for Traefik file provider"
  type        = string
  default     = ""
}

variable "extra_files" {
  type = list(object({
    path    = string
    content = string
  }))
  description = "Extra files to write to the VM at cloud-init time"
  default     = []
}

variable "file_provider_path" {
  description = "Path where the file provider config is mounted"
  type        = string
  default     = "/etc/traefik-hub/dynamic"
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
  default     = true
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
