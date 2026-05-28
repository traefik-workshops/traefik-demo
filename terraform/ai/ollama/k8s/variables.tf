variable "name" {
  type        = string
  description = "Name of the Ollama Helm release."
  default     = "ollama"
}

variable "namespace" {
  type        = string
  description = "Namespace for the Ollama Helm release."
  default     = "ollama"
}

variable "enable_qwen" {
  type        = bool
  default     = false
  description = "Enable Qwen model"
}

variable "enable_deepseek" {
  type        = bool
  default     = false
  description = "Enable DeepSeek model"
}

variable "enable_llama" {
  type        = bool
  default     = false
  description = "Enable Llama model"
}
