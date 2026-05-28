variable "name" {
  type        = string
  description = "Name of the Presidio Helm release."
  default     = "presidio"
}

variable "namespace" {
  type        = string
  description = "Namespace for the Presidio Helm release."
  default     = "presidio"
}
  