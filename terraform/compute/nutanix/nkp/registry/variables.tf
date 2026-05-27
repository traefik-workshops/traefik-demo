variable "cluster_name" {
  description = "Name of the cluster to prefix the VM name"
  type        = string
}

variable "nutanix_cluster_id" {
  description = "Nutanix Cluster UUID"
  type        = string
}

variable "subnet_uuid" {
  description = "Subnet UUID for the Registry VM"
  type        = string
}

variable "registry_image_uuid" {
  description = "UUID of the NKP Registry Image"
  type        = string
}

variable "private_ip" {
  description = "Optional private IP for the registry VM"
  type        = string
  default     = null
}

variable "public_ip" {
  description = "Optional public IP for the registry VM"
  type        = string
  default     = null
}

variable "docker_hub_username" {
  description = "Docker Hub Username"
  type        = string
  default     = ""
}

variable "docker_hub_access_token" {
  description = "Docker Hub Access Token"
  type        = string
  sensitive   = true
  default     = ""
}
