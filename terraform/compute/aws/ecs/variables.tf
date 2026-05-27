variable "name" {
  description = "Name of the ECS Deployment"
  type        = string
}

variable "clusters" {
  description = "Map of ECS clusters with their applications"
  type = map(object({
    apps = map(object({
      replicas           = optional(number, 1)
      subnet_ids         = optional(list(string), [])
      port               = optional(number, 80)
      docker_image       = optional(string, "traefik/whoami:latest")
      docker_command     = optional(string, "")
      labels             = optional(map(string), {})
      environment        = optional(map(string), {})
      security_group_ids = optional(list(string), [])
    }))
  }))
}

variable "create_vpc" {
  description = "Create VPC if vpc_id is not provided"
  type        = bool
  default     = true
}

variable "vpc_id" {
  description = "VPC ID for ECS resources"
  type        = string
  default     = ""

  validation {
    condition     = var.create_vpc || var.vpc_id != ""
    error_message = "vpc_id must be provided if create_vpc is false"
  }
}

variable "subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
  default     = []

  validation {
    condition     = var.create_vpc || var.subnet_ids != []
    error_message = "subnet_ids must be provided if create_vpc is false"
  }
}

variable "security_group_ids" {
  description = "List of security group IDs"
  type        = list(string)
  default     = []

  validation {
    condition     = var.create_vpc || var.security_group_ids != []
    error_message = "security_group_ids must be provided if create_vpc is false"
  }
}

variable "common_labels" {
  description = "Common labels to apply to all resources"
  type        = map(string)
  default     = {}
}
