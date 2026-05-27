resource "helm_release" "prometheus" {
  name       = var.name
  namespace  = var.namespace
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "77.10.0"
  timeout    = 900
  atomic     = true

  values = [
    yamlencode({
      prometheus = {
        prometheusSpec = {
          scrapeInterval            = "5s"
          evaluationInterval        = "5s"
          enableRemoteWriteReceiver = true
          serviceMonitorSelector = {
            matchLabels = {
              "app.kubernetes.io/instance" = "prometheus"
            }
          }
          podMonitorSelector = {
            matchLabels = {
              "benchmark" = "enabled"
            }
          }

          additionalScrapeConfigs = var.traefik_metrics_job_url != "" ? [
            {
              job_name     = "traefik-otel-metrics"
              metrics_path = var.traefik_metrics_job_metrics_path
              static_configs = [
                {
                  targets = [var.traefik_metrics_job_url]
                }
              ]
            }
          ] : []
        }
      }
      kubeStateMetrics = { enabled = true }
      kube-state-metrics = {
        metricLabelsAllowlist = [
          "nodes=[workload]"
        ]
      }
      nodeExporter = { enabled = true }
      prometheus-node-exporter = {
        prometheus = {
          monitor = {
            relabelings = [
              {
                sourceLabels = ["__meta_kubernetes_pod_node_name"]
                targetLabel  = "node"
              }
            ]
          }
        }
      }
      kubelet = { enabled = true }

      alertmanager             = { enabled = false }
      "prometheus-pushgateway" = { enabled = false }
      grafana                  = { enabled = false }
      kubeApiServer            = { enabled = false }
      kubeControllerManager    = { enabled = false }
      kubeScheduler            = { enabled = false }
      kubeProxy                = { enabled = false }
      kubeEtcd                 = { enabled = false }
      coreDns                  = { enabled = false }
      defaultRules             = { create = false }
    }),
    yamlencode(var.extra_values),
    yamlencode(var.ingress == true ? {
      prometheus = {
        ingress = {
          enabled = true
          hosts   = ["prometheus.${var.ingress_domain}"]
          annotations = merge(
            { "traefik.ingress.kubernetes.io/router.entrypoints" = var.ingress_entrypoint },
            var.ingress_observability ? {} : {
              "traefik.ingress.kubernetes.io/router.observability.accesslogs" = "false"
              "traefik.ingress.kubernetes.io/router.observability.metrics"    = "false"
              "traefik.ingress.kubernetes.io/router.observability.tracing"    = "false"
            },
            var.ingress_annotations,
          )
        }
      }
    } : {})
  ]
}
