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

output "rendered" {
  value = templatefile("${path.module}/cloud-init.tpl", {
    whoami_version = var.whoami_version
    arch           = var.arch
    port           = var.port
  })
}

variable "port" {
  type        = number
  description = "Port for whoami to listen on"
  default     = 80
}
