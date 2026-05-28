variable "name" {
  description = "Name of the Floating IP"
  type        = string
}

variable "external_subnet_uuid" {
  description = "UUID of the external subnet"
  type        = string
}

variable "vm_nic_uuid" {
  description = "UUID of the VM NIC to associate with"
  type        = string
  default     = ""
}

variable "vpc_uuid" {
  description = "UUID of the VPC (required for private_ip association)"
  type        = string
  default     = ""
}

variable "private_ip" {
  description = "Private IP to associate with (required if vm_nic_uuid is not set)"
  type        = string
  default     = ""
}

variable "type" {
  description = "Type of FIP association: 'VM' or 'VPC'"
  type        = string
  validation {
    condition     = contains(["VM", "VPC"], var.type)
    error_message = "Type must be either 'VM' or 'VPC'."
  }
}
