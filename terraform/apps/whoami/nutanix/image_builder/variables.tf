variable "arch" {
  description = "Architecture for the image build (amd64 or arm64)"
  type        = string
  default     = "amd64"
}

variable "vm_name" {
  description = "Name prefix for the image"
  type        = string
  default     = "whoami"
}

variable "image_path" {
  description = "Optional path to a pre-existing image file (skips building but still uploads)"
  type        = string
  default     = null
}
