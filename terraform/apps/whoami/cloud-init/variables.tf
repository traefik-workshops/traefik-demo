variable "whoami_version" {
  type        = string
  description = "The Whoami version to install"
  default     = "v1.10.1"
}

variable "arch" {
  type        = string
  description = "The architecture (amd64, arm64)"
  default     = "amd64"
}

variable "port" {
  type        = number
  description = "Port for whoami to listen on"
  default     = 80
}
