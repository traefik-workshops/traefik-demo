variable "gke_version" {
  type        = string
  default     = ""
  description = "GKE cluster version."
}

variable "cluster_name" {
  type        = string
  description = "GKE cluster name."
}

variable "cluster_location" {
  type        = string
  default     = "us-west1-a"
  description = "GKE cluster location."
}

variable "cluster_node_count" {
  type        = number
  default     = 1
  description = "Number of nodes for the cluster."
}

variable "cluster_node_type" {
  type        = string
  default     = "e2-standard-2"
  description = "Default machine type for cluster"
}

variable "enable_gpu" {
  type        = bool
  default     = false
  description = "Enable GPU node pool"
}

variable "gpu_type" {
  type        = string
  default     = "nvidia-l4"
  description = "GPU type"
}

variable "gpu_count" {
  type        = number
  default     = 1
  description = "GPU count"
}

variable "gpu_node_type" {
  type        = string
  default     = "g2-standard-8"
  description = "GPU node type"
}

variable "gpu_node_count" {
  type        = number
  default     = 1
  description = "GPU node count"
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
