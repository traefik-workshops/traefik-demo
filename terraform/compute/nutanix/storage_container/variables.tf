variable "name" {
  description = "Name of the storage container"
  type        = string
}

variable "cluster_ext_id" {
  description = "The external ID of the Nutanix cluster"
  type        = string
}

variable "replication_factor" {
  description = "Replication factor for data redundancy (2 or 3)"
  type        = number
  default     = 2
}

variable "compression_enabled" {
  description = "Enable inline compression"
  type        = bool
  default     = true
}

variable "erasure_coding_enabled" {
  description = "Enable erasure coding for storage efficiency"
  type        = bool
  default     = false
}
