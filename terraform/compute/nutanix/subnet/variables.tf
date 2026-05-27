variable "name" {
  description = "Name of the subnet"
  type        = string
}

variable "description" {
  description = "Description of the subnet"
  type        = string
  default     = "Managed by Terraform"
}

variable "cluster_id" {
  description = "UUID of the Nutanix Cluster"
  type        = string
}

variable "vlan_id" {
  description = "VLAN ID (Network ID) for the subnet"
  type        = number
}

variable "subnet_cidr" {
  description = "CIDR block for the subnet"
  type        = string
}

variable "gateway_ip" {
  description = "Default gateway IP"
  type        = string
}

variable "dns_nameservers" {
  description = "List of DNS nameservers"
  type        = list(string)
  default     = []
}

variable "is_external" {
  description = "Whether this is an external subnet"
  type        = bool
  default     = false
}
