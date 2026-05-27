# =============================================================================
# Nutanix VM-specific Variables
# =============================================================================
# Shared Traefik variables are defined in shared.tf.
# This file contains only Nutanix platform-specific variables.
# =============================================================================

variable "vm_name" {
  description = "Name of the VM"
  type        = string
}

variable "cluster_id" {
  description = "UUID of the Nutanix Cluster"
  type        = string
}

variable "subnet_uuid" {
  description = "UUID of the Subnet"
  type        = string
}

variable "image_id" {
  description = "UUID of the Image to use"
  type        = string
}

variable "arch" {
  description = "Architecture of the VM"
  type        = string
  default     = "amd64"
}

variable "vm_num_vcpus_per_socket" {
  description = "Number of vCPUs per socket"
  type        = number
  default     = 1
}

variable "vm_num_sockets" {
  description = "Number of sockets"
  type        = number
  default     = 1
}

variable "vm_memory_mib" {
  description = "Memory size in MiB"
  type        = number
  default     = 2048
}

variable "vm_disk_size_mib" {
  description = "Disk size in MiB"
  type        = number
  default     = 20480 # 20 GB
}

variable "vm_static_ip" {
  description = "Optional static IP for the VM's NIC (inside subnet CIDR). Empty = DHCP."
  type        = string
  default     = ""
}

variable "traefik_static_config" {
  description = "Traefik static configuration (YAML string)"
  type        = string
  default     = ""
}

variable "metrics_port" {
  description = "Port for metrics"
  type        = number
  default     = 8082
}

variable "vip" {
  description = "Virtual IP for Keepalived"
  type        = string
  default     = ""
}

variable "keepalived_priority" {
  description = "Priority for Keepalived VRRP (higher wins)"
  type        = number
  default     = 100
}

variable "network_interface" {
  description = "Network interface name for Keepalived VRRP"
  type        = string
  default     = "ens3"
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
