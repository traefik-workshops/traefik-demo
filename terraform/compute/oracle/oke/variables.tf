variable "oke_version" {
  type        = string
  default     = "v1.33.1"
  description = "OKE cluster version."
}

variable "cluster_name" {
  type        = string
  description = "OKE cluster name."
}

variable "cluster_location" {
  type        = string
  default     = "us-chicago-1"
  description = "OKE cluster location."
}

variable "cluster_node_count" {
  type        = number
  default     = 1
  description = "Number of nodes for the cluster."
}

variable "cluster_node_type" {
  type        = string
  default     = "VM.Standard.E4.Flex"
  description = "Default machine type for cluster"
}

# Required OKE variables
variable "compartment_id" {
  type        = string
  default     = "ocid1.compartment.oc1..aaaaaaaa5lzebpklmesa7hqpi5242wdiqhhe5tjnha44ccxzcj4coekjpjvq"
  description = "Oracle Cloud compartment ID."
}

variable "worker_nodes" {
  type = list(object({
    label = string
    taint = string
    count = number
  }))
  default     = []
  description = "Worker node pool definitions. Each entry creates a dedicated node pool with the given label and taint. Note: OKE does not support native taints; they are applied via kubectl post-creation."
}

variable "update_kubeconfig" {
  type        = bool
  default     = true
  description = "Update kubeconfig after cluster creation"
}
