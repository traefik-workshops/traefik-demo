variable "nkp_version" {
  description = "Nutanix Kubernetes Platform release version embedded in the registry image (e.g. `2.17.1`). Used by Packer to pull the matching `nkp` CLI out of the bundle tarball."
  type        = string
  default     = "2.17.1"
}

variable "nkp_bundle_path" {
  description = "Absolute or `~`-prefixed path to the NKP airgap bundle tarball. The build step extracts the `nkp` CLI and feeds the bundle to Packer to assemble the registry qcow2."
  type        = string
  default     = ""
}
