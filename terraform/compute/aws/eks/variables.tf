variable "eks_version" {
  type        = string
  default     = ""
  description = "EKS cluster version."
}

variable "cluster_name" {
  type        = string
  description = "EKS cluster name."
}

variable "cluster_location" {
  type        = string
  default     = "us-west-1"
  description = "EKS cluster location."
}

variable "cluster_node_count" {
  type        = number
  default     = 1
  description = "Number of nodes for the cluster."
}

variable "cluster_node_type" {
  type        = string
  default     = "t3.medium"
  description = "Default machine type for cluster"
}

variable "cluster_node_ami_type" {
  type        = string
  default     = "AL2023_x86_64_STANDARD"
  description = "EKS cluster AMI Type."
}

variable "worker_nodes" {
  type = list(object({
    label = string
    taint = string
    count = number
  }))
  default     = []
  description = "Worker node pool definitions. Each entry creates a dedicated node group with the given label and taint."
}

variable "update_kubeconfig" {
  type        = bool
  default     = true
  description = "Update kubeconfig after cluster creation"
}

variable "create_vpc" {
  description = "Create VPC if vpc_id is not provided"
  type        = bool
  default     = true
}

variable "vpc_id" {
  type        = string
  default     = ""
  description = "VPC ID for the cluster."

  validation {
    condition     = var.create_vpc || var.vpc_id != ""
    error_message = "vpc_id must be provided if create_vpc is false"
  }
}

variable "private_subnet_ids" {
  type        = list(string)
  default     = []
  description = "Private subnets for the cluster."

  validation {
    condition     = var.create_vpc || var.private_subnet_ids != []
    error_message = "private_subnet_ids must be provided if create_vpc is false"
  }
}

variable "public_subnet_ids" {
  type        = list(string)
  default     = []
  description = "Public subnets for the cluster."

  validation {
    condition     = var.create_vpc || var.public_subnet_ids != []
    error_message = "public_subnet_ids must be provided if create_vpc is false"
  }
}

