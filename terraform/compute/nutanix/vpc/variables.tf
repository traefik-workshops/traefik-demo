variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

variable "vpc_type" {
  description = "Type of VPC (REGULAR or TRANSIT)"
  type        = string
  default     = "REGULAR"
}

variable "external_subnet_uuid" {
  description = "UUID of the external subnet to connect to"
  type        = string
}

variable "subnets" {
  description = "Map of subnets to create. Key is the subnet name."
  type = map(object({
    cidr          = string
    prefix_length = optional(number)
    subnet_type   = optional(string)
    extra_ip      = optional(string)
  }))
  default = {}
}

variable "dns_servers" {
  description = "List of DNS Servers"
  type        = list(string)
  default     = ["10.8.1.10", "10.42.196.10"]
}

variable "externally_routable_prefixes" {
  description = "List of externally routable prefixes"
  type        = list(string)
  default     = []
}
