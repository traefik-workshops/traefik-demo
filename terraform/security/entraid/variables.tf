variable "users" {
  type        = list(string)
  default     = ["admin", "support"]
  description = "EntraID users to be created"
}

variable "redirect_uris" {
  type        = list(string)
  default     = []
  description = "EntraID redirect URIs"
}

variable "user_password" {
  description = "Initial password assigned to every created EntraID user. Demo default — override for anything beyond ephemeral PoCs."
  type        = string
  sensitive   = true
  default     = "topsecretpassword"
}
