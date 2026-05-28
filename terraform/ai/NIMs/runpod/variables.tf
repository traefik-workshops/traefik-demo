variable "runpod_api_key" {
  description = "RunPod API key"
  type        = string
  sensitive   = false
}

variable "ngc_token" {
  description = "NVIDIA NGC API token"
  type        = string
  sensitive   = false
}

variable "ngc_username" {
  description = "NVIDIA NGC username (usually '$oauthtoken' for API auth)"
  type        = string
  default     = "$oauthtoken"
}

variable "pod_type" {
  description = "The type of pod to deploy (e.g., NVIDIA L40, NVIDIA A100, etc.)"
  type        = string
  default     = "NVIDIA A40"
}

# Topic Control NIM
variable "enable_topic_control_nim" {
  description = "Configuration for Topic Control NIM"
  type        = bool
  default     = false
}

# Content Safety NIM
variable "enable_content_safety_nim" {
  description = "Configuration for Content Safety NIM"
  type        = bool
  default     = false
}

# Jailbreak Detection NIM
variable "enable_jailbreak_detection_nim" {
  description = "Configuration for Jailbreak Detection NIM"
  type        = bool
  default     = false
}
