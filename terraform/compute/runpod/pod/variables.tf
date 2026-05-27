variable "runpod_api_key" {
  description = "RunPod API key"
  type        = string
  sensitive   = true
}

variable "ngc_token" {
  description = "NVIDIA NGC API token"
  type        = string
  sensitive   = true
  default     = ""
}

variable "registry_auth_id" {
  description = "ID of the registry auth"
  type        = string
  default     = ""
}

variable "hugging_face_api_key" {
  description = "Hugging Face API key"
  type        = string
  sensitive   = true
  default     = ""
}

variable "pods" {
  type = any
}