variable "name" {
  description = "Name of the ConfigMap holding the AI Gateway dashboard JSON (Grafana's sidecar picks it up by label)."
  type        = string
}

variable "namespace" {
  description = "Namespace to create the dashboard ConfigMap in — usually the namespace Grafana watches for dashboard ConfigMaps."
  type        = string
}

resource "kubernetes_config_map_v1" "grafana_aigateway_dashboards" {
  metadata {
    name      = var.name
    namespace = var.namespace
  }

  data = {
    "dashboard.json" = "${file("${path.module}/dashboard.json")}"
  }
}
