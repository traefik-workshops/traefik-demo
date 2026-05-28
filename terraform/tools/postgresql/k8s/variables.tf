variable "name" {
  description = "Name of the PostgreSQL Helm release."
  type        = string
  default     = "postgresql"
}

variable "namespace" {
  description = "Namespace for the PostgreSQL deployment."
  type        = string
}


variable "password" {
  description = "PostgreSQL password. DEMO DEFAULT — override per environment."
  type        = string
  default     = "topsecretpassword"
  sensitive   = true
}

variable "database" {
  description = "Database name"
  type        = string
  default     = "postgres"
}

variable "extra_values" {
  description = "Extra values to merge into the Helm chart values"
  type        = any
  default     = {}
}
