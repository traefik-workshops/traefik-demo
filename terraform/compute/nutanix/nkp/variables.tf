variable "cluster_name" {
  description = "Name of the NKP cluster"
  type        = string
}

variable "nutanix_cluster_id" {
  description = "Nutanix Cluster UUID"
  type        = string
}

variable "nutanix_prism_element_cluster_name" {
  description = "Nutanix Prism Element Cluster Name (for NKP configuration)"
  type        = string
}

variable "bastion_subnet_uuid" {
  description = "Subnet UUID for the Bastion VM"
  type        = string
}

variable "external_subnet_uuid" {
  description = "UUID of the External Subnet for Floating IP"
  type        = string
}

variable "cluster_subnets" {
  description = "List of Subnet Names or UUIDs for the NKP nodes"
  type        = list(string)
}

variable "vpc_uuid" {
  description = "UUID of the VPC where the NKP cluster is deployed"
  type        = string
}

variable "control_plane_vip" {
  description = "Control Plane VIP"
  type        = string
}

variable "control_plane_fip" {
  description = "Control Plane FIP"
  type        = string
  default     = ""
}

variable "lb_ip_range" {
  description = "Load Balancer IP Range"
  type        = string
}

variable "nutanix_username" {
  description = "Nutanix Username"
  type        = string
}

variable "nutanix_password" {
  description = "Nutanix Password"
  type        = string
  sensitive   = true
}

variable "nutanix_endpoint" {
  description = "Nutanix Endpoint (Prism Central IP)"
  type        = string
}

variable "nutanix_port" {
  description = "Nutanix Port"
  type        = number
  default     = 9440
}

variable "nutanix_insecure" {
  description = "Allow insecure connection to Nutanix"
  type        = bool
  default     = true
}

variable "nkp_version" {
  description = "NKP Version"
  type        = string
  default     = "2.17.1"
}

variable "nkp_image_name" {
  description = "Name of the NKP OS Image"
  type        = string
}

variable "nkp_image_uuid" {
  description = "UUID of the NKP OS Image"
  type        = string
}

variable "registry_mirror_url" {
  description = "Registry Mirror URL"
  type        = string
  default     = ""

  validation {
    condition     = var.registry_mirror_url == "" || can(regex("^https?://", var.registry_mirror_url))
    error_message = "The registry_mirror_url must start with http:// or https:// (e.g., https://registry.example.com)."
  }
}

variable "storage_container" {
  description = "Nutanix Storage Container Name"
  type        = string
  default     = "Default"
}

variable "bastion_image_name" {
  description = "Name of the image to use for bastion if already exists or to create"
  type        = string
  default     = "nkp-bastion-image"
}

variable "bastion_vm_username" {
  description = "Username for the Bastion VM"
  type        = string
  default     = "traefiker"
}

variable "bastion_vm_password" {
  description = "Password for the Bastion VM"
  type        = string
  sensitive   = false
  default     = "topsecretpassword"
}

variable "control_plane_replicas" {
  description = "Number of Control Plane Nodes"
  type        = number
  default     = 3
}

variable "worker_replicas" {
  description = "Number of Worker Nodes"
  type        = number
  default     = 4
}

variable "control_plane_memory_mib" {
  description = "Memory in MiB for Control Plane Nodes"
  type        = number
  default     = 65536
}

variable "control_plane_vcpus" {
  description = "vCPUs for Control Plane Nodes"
  type        = number
  default     = 32
}

variable "worker_memory_mib" {
  description = "Memory in MiB for Worker Nodes"
  type        = number
  default     = 65536
}

variable "worker_vcpus" {
  description = "vCPUs for Worker Nodes"
  type        = number
  default     = 32
}

variable "update_kubeconfig" {
  description = "Update local kubeconfig with cluster context"
  type        = bool
  default     = true
}

variable "kubernetes_version" {
  description = "Kubernetes Version"
  type        = string
  default     = ""
}

variable "enable_kommander_traefik_fip" {
  description = "Enable Load Balancer FIP creation"
  type        = bool
  default     = false
}
