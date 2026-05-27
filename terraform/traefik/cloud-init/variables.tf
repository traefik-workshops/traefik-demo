variable "arch" {
  type        = string
  description = "The architecture (amd64, arm64)"
  default     = "amd64"
}

variable "traefik_hub_version" {
  type        = string
  description = "The Traefik Hub version to download"
}

variable "enable_preview_mode" {
  description = "Enable Traefik Hub Preview features (pulls binary from Docker image instead of GitHub releases)"
  type        = bool
  default     = false
}

variable "preview_image" {
  description = "Full Docker image reference for preview mode (e.g. europe-west9-docker.pkg.dev/traefiklabs/traefik-hub/traefik-hub:latest-v3)"
  type        = string
  default     = ""
}

variable "cli_arguments" {
  type        = list(string)
  description = "CLI arguments for Traefik Hub"
  default     = []
}

variable "env_vars" {
  type = list(object({
    name  = string
    value = string
  }))
  description = "Environment variables for Traefik Hub"
  default     = []
}

variable "file_provider_config" {
  type        = string
  description = "Dynamic configuration for the file provider"
  default     = ""
}

variable "extra_files" {
  type = list(object({
    path    = string
    content = string
  }))
  description = "Extra files to write to the VM at cloud-init time (e.g. Nutanix provider supplementary config)"
  default     = []
}

variable "dashboard_config" {
  type        = string
  description = "Dashboard configuration"
  default     = ""
}

variable "performance_tuning" {
  type = object({
    limit_nofile        = number
    gomaxprocs          = number
    gogc                = number
    tcp_tw_reuse        = number
    tcp_timestamps      = number
    rmem_max            = number
    wmem_max            = number
    somaxconn           = number
    netdev_max_backlog  = number
    ip_local_port_range = string
    numa_node           = number
  })
  description = "Performance tuning settings"
  default = {
    limit_nofile        = 500000
    gomaxprocs          = 0
    gogc                = 100
    tcp_tw_reuse        = 1
    tcp_timestamps      = 1
    rmem_max            = 16777216
    wmem_max            = 16777216
    somaxconn           = 4096
    netdev_max_backlog  = 4096
    ip_local_port_range = "1024 65535"
    numa_node           = -1
  }
}

variable "vip" {
  type        = string
  description = "Virtual IP for Keepalived"
  default     = ""
}

variable "keepalived_priority" {
  type        = number
  description = "Priority for Keepalived VRRP"
  default     = 100
}

variable "network_interface" {
  type        = string
  description = "Network interface for Keepalived"
  default     = "ens3"
}

variable "otlp_address" {
  type        = string
  description = "OTLP endpoint URL (e.g. https://collector.example.com)"
  default     = ""
}

variable "instance_name" {
  type        = string
  description = "Unique name for this instance (used for metrics identity)"
  default     = "traefik-node"
}

variable "dns_traefiker" {
  description = "DNS Traefiker configuration for automatic domain registration"
  type = object({
    enabled                   = optional(bool, false)
    version                   = optional(string, "v1.0.4")
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