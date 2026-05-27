variable "nkp_version" {
  type    = string
  default = "2.17.1"
}

variable "nkp_bundle_file" {
  type    = string
  default = ""
}

variable "nkp_bundle_path" {
  type    = string
  default = ""
}

variable "nkp_cli_path" {
  description = "Optional path to a pre-existing NKP CLI binary (skips extraction from bundle)"
  type        = string
  default     = null
}
