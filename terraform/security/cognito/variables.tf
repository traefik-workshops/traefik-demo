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
