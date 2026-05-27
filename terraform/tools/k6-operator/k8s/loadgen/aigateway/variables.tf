variable "apis" {
  type = list(object({
    url    = string
    models = list(string)
  }))
}

variable "users" {
  type = list(object({
    username = string
    password = string
  }))
  description = "List of users with credentials for JWT authentication"
}

variable "keycloak_url" {
  type        = string
  description = "Keycloak token endpoint URL"
}

variable "keycloak_client_id" {
  type        = string
  description = "Keycloak client ID"
}

variable "keycloak_client_secret" {
  type        = string
  description = "Keycloak client secret"
  sensitive   = true
}

variable "min_messages_per_conversation" {
  type        = number
  description = "Minimum number of messages in a conversation"
  default     = 3
}

variable "max_messages_per_conversation" {
  type        = number
  description = "Maximum number of messages in a conversation"
  default     = 8
}
