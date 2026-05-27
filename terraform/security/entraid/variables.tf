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
