locals {
  loki_exporter       = var.enable_loki ? ["otlphttp/loki"] : []
  tempo_exporter      = var.enable_tempo ? ["otlphttp/tempo"] : []
  newrelic_exporter   = var.enable_new_relic ? ["otlphttp/nri"] : []
  dash0_exporter      = var.enable_dash0 ? ["otlphttp/dash0"] : []
  honeycomb_exporter  = var.enable_honeycomb ? ["otlphttp/honeycomb"] : []
  langsmith_exporter  = var.enable_langsmith ? ["otlphttp/langsmith"] : []
  langfuse_exporter   = var.enable_langfuse ? ["otlphttp/langfuse"] : []
  prometheus_exporter = var.enable_prometheus ? ["prometheus"] : []

  log_exporters    = concat(local.loki_exporter, local.newrelic_exporter, local.dash0_exporter, local.honeycomb_exporter)
  trace_exporters  = concat(local.tempo_exporter, local.newrelic_exporter, local.dash0_exporter, local.honeycomb_exporter, local.langsmith_exporter, local.langfuse_exporter)
  metric_exporters = concat(local.newrelic_exporter, local.dash0_exporter, local.honeycomb_exporter, local.prometheus_exporter)

  logs_pipeline = length(local.log_exporters) > 0 ? concat([
    {
      name  = "config.service.pipelines.logs.receivers[0]"
      value = "otlp"
    },
    {
      name  = "config.service.pipelines.logs.processors[0]"
      value = "batch"
    }
    ], [for exporter in local.log_exporters : {
      name  = "config.service.pipelines.logs.exporters[${index(local.log_exporters, exporter)}]"
      value = exporter
  }]) : []

  metrics_pipeline = length(local.metric_exporters) > 0 ? concat([
    {
      name  = "config.service.pipelines.metrics.receivers[0]"
      value = "otlp"
    },
    {
      name  = "config.service.pipelines.metrics.processors[0]"
      value = "batch"
    }
    ], [for exporter in local.metric_exporters : {
      name  = "config.service.pipelines.metrics.exporters[${index(local.metric_exporters, exporter)}]"
      value = exporter
  }]) : []

  traces_pipeline = length(local.trace_exporters) > 0 ? concat([
    {
      name  = "config.service.pipelines.traces.receivers[0]"
      value = "otlp"
    },
    {
      name  = "config.service.pipelines.traces.processors[0]"
      value = "batch"
    }
    ], [for exporter in local.trace_exporters : {
      name  = "config.service.pipelines.traces.exporters[${index(local.trace_exporters, exporter)}]"
      value = exporter
  }]) : []

  service_pipelines = concat(local.logs_pipeline, local.metrics_pipeline, local.traces_pipeline)
}

resource "helm_release" "opentelemetry" {
  name       = var.name
  namespace  = var.namespace
  repository = "https://open-telemetry.github.io/opentelemetry-helm-charts"
  chart      = "opentelemetry-collector"
  version    = "0.127.2"
  timeout    = 900
  atomic     = true

  values = [
    yamlencode({
      mode = "deployment"
      image = {
        repository = "otel/opentelemetry-collector-contrib"
        tag        = "latest"
      }
      ports = {
        metrics = {
          enabled       = true
          containerPort = var.prometheus_port
          servicePort   = var.prometheus_port
        }
      }
      config = {
        receivers = {
          otlp = {
            protocols = {
              http = {
                endpoint = "0.0.0.0:4318"
              }
              grpc = {
                endpoint = "0.0.0.0:4317"
              }
            }
          }
        }
        processors = {
          batch = {
            timeout = "5s"
          }
        }
        exporters = merge(
          var.enable_loki ? {
            "otlphttp/loki" = {
              endpoint = var.loki_endpoint
              tls = {
                insecure = true
              }
            }
            } : {}, var.enable_tempo ? {
            "otlphttp/tempo" = {
              endpoint = var.tempo_endpoint
              tls = {
                insecure = true
              }
            }
            } : {}, var.enable_new_relic ? {
            "otlphttp/nri" = {
              endpoint = var.newrelic_endpoint
              headers = {
                api-key = var.newrelic_license_key
              }
            }
            } : {}, var.enable_dash0 ? {
            "otlphttp/dash0" = {
              endpoint = var.dash0_endpoint
              headers = {
                Authorization = "Bearer ${var.dash0_auth_token}"
                Dash0-Dataset = var.dash0_dataset
              }
            }
            } : {}, var.enable_honeycomb ? {
            "otlphttp/honeycomb" = {
              endpoint = var.honeycomb_endpoint
              headers = {
                x-honeycomb-team    = var.honeycomb_api_key
                x-honeycomb-dataset = var.honeycomb_dataset
              }
            }
            } : {}, var.enable_langsmith ? {
            "otlphttp/langsmith" = {
              endpoint    = var.langsmith_endpoint
              compression = "gzip"
              headers = {
                x-api-key         = var.langsmith_api_key
                Langsmith-Project = var.langsmith_project
              }
            }
            } : {}, var.enable_langfuse ? {
            "otlphttp/langfuse" = {
              endpoint    = var.langfuse_endpoint
              compression = "gzip"
              headers = {
                Authorization = "Basic ${base64encode("${var.langfuse_public_key}:${var.langfuse_secret_key}")}"
              }
            }
            } : {}, var.enable_prometheus ? {
            "prometheus" = {
              endpoint = "0.0.0.0:${var.prometheus_port}"
            }
        } : {}, {})
      }
      }
    ),
    yamlencode(var.ingress == true ? {
      ingress = {
        enabled = true
        hosts = [{
          host = "collector.${var.ingress_domain}"
          paths = [{
            path     = "/"
            pathType = "Prefix"
            port     = 4318
          }]
        }]
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
    } : {})
  ]

  set = local.service_pipelines
}
