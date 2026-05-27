variable "apps" {
  description = "Map of applications to deploy with multiple replicas"
  type = map(object({
    replicas            = optional(number, 1)
    subnet_ids          = optional(list(string), [])
    port                = optional(number, 80)
    docker_image        = optional(string, "traefik/whoami:latest")
    docker_options      = optional(string, "") # Docker run flags: -e, -p, -v, etc.
    container_arguments = optional(string, "") # Container CMD/ARGS: --flag=value, etc.
    tags                = optional(map(string), {})
  }))
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.large"
}

variable "ami_architecture" {
  description = "AMI architecture (x86_64 or arm64)"
  type        = string
  default     = "x86_64"
}

variable "replica_start_index" {
  description = "Starting index for replica numbering (Default: 1)"
  type        = number
  default     = 1
}

variable "common_tags" {
  description = "Common tags to apply to all instances"
  type        = map(string)
  default     = {}
}

variable "create_vpc" {
  description = "Create VPC if vpc_id is not provided"
  type        = bool
  default     = true
}

variable "vpc_id" {
  description = "VPC ID"
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
  description = "List of security group IDs to associate with the instances (used if not creating VPC)"
  type        = list(string)
  default     = []

  validation {
    condition     = var.create_vpc || var.security_group_ids != []
    error_message = "security_group_ids must be provided if create_vpc is false"
  }
}

variable "iam_instance_profile" {
  description = "IAM instance profile name to attach to EC2 instances"
  type        = string
  default     = ""
}

variable "enable_acme_setup" {
  description = "Enable ACME storage setup for Let's Encrypt certificates"
  type        = bool
  default     = false
}

variable "user_data_override" {
  description = "Optional user data script to override the default Docker-based generation"
  type        = string
  default     = ""
}

variable "user_data_overrides" {
  description = "Optional map of user data scripts to override the default Docker-based generation per instance key"
  type        = map(string)
  default     = {}
}

variable "root_block_device_size" {
  description = "Root block device size in GB"
  type        = number
  default     = 20
}

variable "associate_public_ip_address" {
  description = "Associate a public IP address with an instance in a VPC"
  type        = bool
  default     = true
}
