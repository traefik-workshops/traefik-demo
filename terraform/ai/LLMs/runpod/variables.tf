variable "runpod_api_key" {
  description = "RunPod API key"
  type        = string
  sensitive   = false
}

variable "enable_llama31_8b" {
  description = "Enable Llama31 8B"
  type        = bool
  default     = false
}

variable "enable_gpt_oss_20b" {
  description = "Enable GPT OSS 20B"
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
  