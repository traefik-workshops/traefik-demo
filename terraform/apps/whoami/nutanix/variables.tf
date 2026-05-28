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
  default     = 1024
}

variable "service_name" {
  description = "Service name for Nutanix Prism Central discovery (TraefikServiceName category)"
  type        = string
  default     = "whoami"
}

variable "service_port" {
  description = "Service port for Nutanix Prism Central discovery (TraefikServicePort category)"
  type        = number
  default     = 8080
}

variable "load_balancer_strategy" {
  description = "Load balancer strategy for Nutanix Prism Central discovery (TraefikLoadBalancerStrategy category)"
  type        = string
  default     = ""
}

variable "whoami_version" {
  description = "The Whoami version to install"
  type        = string
  default     = "v1.10.1"
}
