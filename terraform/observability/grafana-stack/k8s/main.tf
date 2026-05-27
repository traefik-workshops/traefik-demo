module "observability-prometheus" {
  source = "../../prometheus/k8s"

  namespace             = var.namespace
  tolerations           = var.tolerations
  extra_values          = var.prometheus_extra_values
  ingress               = var.ingress
  ingress_domain        = var.ingress_domain
  ingress_entrypoint    = var.ingress_entrypoint
  ingress_observability = var.ingress_observability
  ingress_annotations   = var.ingress_annotations

  traefik_metrics_job_url = "${var.metrics_host}:${var.metrics_port}"
}

module "observability-grafana-loki" {
  source = "../../grafana-loki/k8s"

  namespace   = var.namespace
  tolerations = var.tolerations
}

module "observability-grafana-tempo" {
  source = "../../grafana-tempo/k8s"

  namespace   = var.namespace
  tolerations = var.tolerations
}

module "grafana" {
  source = "../../grafana/k8s"

  namespace             = var.namespace
  tolerations           = var.tolerations
  extra_values          = var.grafana_extra_values
  ingress               = var.ingress
  ingress_domain        = var.ingress_domain
  ingress_entrypoint    = var.ingress_entrypoint
  ingress_observability = var.ingress_observability
  ingress_annotations   = var.ingress_annotations
  dashboards            = var.dashboards
  extra_dashboards      = var.extra_dashboards

  prometheus = {
    enabled = true
    url = {
      service   = "prometheus-kube-prometheus-prometheus"
      port      = 9090
      namespace = ""
      override  = var.prometheus_url_override
    }
  }

  tempo = {
    enabled = true
    url = {
      service   = "tempo"
      port      = 3200
      namespace = ""
      override  = ""
    }
  }

  loki = {
    enabled = true
    url = {
      service   = "loki"
      port      = 3100
      namespace = ""
      override  = ""
    }
  }
}
