variable "users" {
  type        = list(string)
  default     = ["admin", "support"]
  description = "List of Cognito users to be created"
}

variable "redirect_uris" {
  type        = list(string)
  default     = []
  description = "Allowed callback URL for the authentication flow"
}

variable "user_password" {
  description = "Initial password assigned to every created Cognito user. Demo default — override for anything beyond ephemeral PoCs."
  type        = string
  sensitive   = true
  default     = "topsecretpassword"
}
