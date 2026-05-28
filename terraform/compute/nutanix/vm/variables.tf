variable "name" {
  description = "Name of the VM"
  type        = string
}

variable "cluster_uuid" {
  description = "UUID of the Nutanix Cluster"
  type        = string
}

variable "subnet_uuid" {
  description = "UUID of the Subnet"
  type        = string
}

variable "image_uuid" {
  description = "UUID of the source image"
  type        = string
}

variable "num_vcpus_per_socket" {
  description = "Number of vCPUs per socket"
  type        = number
  default     = 1
}

variable "num_sockets" {
  description = "Number of sockets"
  type        = number
  default     = 1
}

variable "memory_size_mib" {
  description = "Memory size in MiB"
  type        = number
  default     = 2048
}

variable "disk_size_mib" {
  description = "Disk size in MiB. Overrides the source image disk size."
  type        = number
  default     = 20480 # 20 GB
}

variable "cloud_init_user_data" {
  description = "Cloud-Init User Data (YAML string). Will be base64 encoded by the module."
  type        = string
  default     = ""
}

variable "categories" {
  description = "Map of category key-value pairs to assign to the VM"
  type        = map(string)
  default     = {}
}

variable "static_ip" {
  description = "Optional static IP to assign to the primary NIC. Must be inside the subnet's CIDR. Leave empty to let DHCP assign."
  type        = string
  default     = ""
}
