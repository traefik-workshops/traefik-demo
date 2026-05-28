variable "name" {
  description = "Name of the ConfigMap holding the AI Gateway dashboard JSON (Grafana's sidecar picks it up by label)."
  type        = string
}

variable "namespace" {
  description = "Namespace to create the dashboard ConfigMap in — usually the namespace Grafana watches for dashboard ConfigMaps."
  type        = string
}
