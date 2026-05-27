variable "name" {
  type        = string
  description = "The name of the milvus release"
  default     = "milvus"
}

variable "namespace" {
  type        = string
  description = "The namespace of the milvus release"
  default     = "milvus"
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
