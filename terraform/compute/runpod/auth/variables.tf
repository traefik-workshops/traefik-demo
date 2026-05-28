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