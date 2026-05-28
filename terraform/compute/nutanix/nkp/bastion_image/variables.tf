variable "nkp_version" {
  description = "Nutanix Kubernetes Platform release version embedded in the bastion image (e.g. `2.17.1`). Used by Packer to pull the matching `nkp` CLI out of the bundle tarball."
  type        = string
  default     = "2.17.1"
}

variable "nkp_bundle_file" {
  description = "Filename of the NKP airgap bundle tarball — kept for callers that need to reference the basename separately. Pair with `nkp_bundle_path` for the full path."
  type        = string
  default     = ""
}

variable "nkp_bundle_path" {
  description = "Absolute or `~`-prefixed path to the NKP airgap bundle tarball. The build step extracts the `nkp` CLI and feeds the bundle to Packer to assemble the bastion qcow2."
  type        = string
  default     = ""
}

variable "nkp_cli_path" {
  description = "Optional path to a pre-existing NKP CLI binary (skips extraction from bundle)"
  type        = string
  default     = null
}
