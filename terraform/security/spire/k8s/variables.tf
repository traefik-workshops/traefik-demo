variable "name" {
  type        = string
  description = "Helm release name for the SPIRE umbrella chart (server + agent + CSI driver + controller-manager)."
  default     = "spire"
}

variable "namespace" {
  type        = string
  description = "Namespace to install SPIRE into."
  default     = "spire"
}

variable "create_namespace" {
  type        = bool
  description = "Create the namespace before installing. Set false if the caller already manages it."
  default     = true
}

variable "trust_domain" {
  type        = string
  description = "SPIFFE trust domain that roots every SVID this server issues (e.g. \"eks.example.org\"). Each cluster in a federation MUST use a distinct trust domain."
  default     = "example.org"
}

variable "cluster_name" {
  type        = string
  description = "Logical cluster name SPIRE uses for node attestation and SVID paths."
  default     = "demo"
}

variable "ca_subject" {
  type = object({
    country      = string
    organization = string
    common_name  = string
  })
  description = "Subject of the SPIRE server's self-signed CA."
  default = {
    country      = "US"
    organization = "Traefik Demo"
    common_name  = "spire"
  }
}

variable "enable_federation" {
  type        = bool
  description = "Expose the SPIRE server federation bundle endpoint so peer trust domains can fetch this cluster's trust bundle. Required for cross-cluster SPIFFE-mTLS uplinks; pair with ClusterFederatedTrustDomain resources (managed by the consuming demo) pointing at each peer's bundle endpoint."
  default     = false
}

variable "spire_chart_version" {
  type        = string
  description = "Pinned version of the `spire` umbrella chart (spiffe/helm-charts-hardened)."
  default     = "0.28.4"
}

variable "spire_crds_chart_version" {
  type        = string
  description = "Pinned version of the `spire-crds` chart (spiffe/helm-charts-hardened)."
  default     = "0.5.0"
}

variable "chart_repository" {
  type        = string
  description = "Helm chart repository URL for the SPIRE hardened charts."
  default     = "https://spiffe.github.io/helm-charts-hardened/"
}

variable "values" {
  type        = any
  description = "Additional Helm values for the `spire` chart, deep-merged on top of the module's base values (trust domain, cluster name, CA subject, federation). Use for node attestors (e.g. aws_iid), ClusterSPIFFEID defaults, and resource tuning."
  default     = {}
}
