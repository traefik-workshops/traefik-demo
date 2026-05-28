variable "kubeconfig" {
  type        = string
  description = "Full kubeconfig contents for the existing Kubernetes cluster. Pass via `file(\"~/.kube/config\")` or read from a `data.local_file`. The module extracts host / CA / token from the current context (or the first context if `current-context` is unset). Sensitive."
  sensitive   = true
}

variable "cluster_name" {
  type        = string
  description = "Logical name for the imported cluster — surfaced in outputs so downstream modules can tag resources consistently. Pure metadata; no resources are renamed based on it."
  default     = "imported"
}
