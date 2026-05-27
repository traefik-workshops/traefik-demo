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
