variable "runpod_api_key" {
  description = "RunPod API key"
  type        = string
  sensitive   = false
}

variable "enable_granite_guardian" {
  description = "Enable Granite Guardian"
  type        = bool
  default     = false
}

variable "pod_type" {
  description = "Pod type"
  type        = string
  default     = "NVIDIA A40"
}

variable "hugging_face_api_key" {
  description = "Hugging Face API key"
  type        = string
  sensitive   = true
}
