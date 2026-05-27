variable "doks_version" {
  type        = string
  default     = "1.33.1-do.3"
  description = "DOKS Kubernetes version"
}

variable "cluster_name" {
  type        = string
  description = "DOKS cluster name"
}

variable "cluster_location" {
  type        = string
  default     = "nyc2"
  description = "DOKS cluster region"
}

variable "cluster_node_type" {
  type        = string
  default     = "s-1vcpu-2gb"
  description = "Default droplet size for cluster nodes"
}

variable "cluster_node_count" {
  type        = number
  default     = 1
  description = "Number of nodes for the cluster"
}

variable "enable_autoscaling" {
  type        = bool
  default     = false
  description = "Enable autoscaling for default node pool"
}

variable "min_nodes" {
  type        = number
  default     = 1
  description = "Minimum number of nodes in the default node pool"
}

variable "max_nodes" {
  type        = number
  default     = 1
  description = "Maximum number of nodes in the default node pool"
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

variable "namespace" {
  type        = string
  default     = "default"
  description = "Kubernetes namespace to use for resources"
}
variable "update_kubeconfig" {
  type        = bool
  default     = true
  description = "Update kubeconfig after cluster creation"
}