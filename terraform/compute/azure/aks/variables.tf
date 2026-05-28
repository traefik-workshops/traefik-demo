variable "resource_group_name" {
  type        = string
  description = "Resource group name"
}

variable "aks_version" {
  type        = string
  default     = "1.34"
  description = "AKS Kubernetes version"
}

variable "cluster_name" {
  type        = string
  description = "AKS cluster name"
}

variable "cluster_location" {
  type        = string
  default     = "westus"
  description = "AKS cluster location"
}

variable "cluster_node_type" {
  type        = string
  default     = "Standard_B2s"
  description = "Default node type for cluster"
}

variable "cluster_node_count" {
  type        = number
  default     = 1
  description = "Number of nodes for the cluster"
}

variable "enable_gpu" {
  type        = bool
  default     = false
  description = "Enable GPU nodes"
}

variable "gpu_node_type" {
  type        = string
  default     = ""
  description = "GPU node type for cluster"
}

variable "gpu_node_count" {
  type        = number
  default     = 1
  description = "Number of GPU nodes for the cluster"
}

variable "worker_nodes" {
  type = list(object({
    label = string
    taint = string
    count = number
  }))
  default     = []
  description = "Worker node pool definitions. Each entry creates a dedicated node pool with the given label and taint."
}

variable "update_kubeconfig" {
  type        = bool
  default     = true
  description = "Update kubeconfig after cluster creation"
}
