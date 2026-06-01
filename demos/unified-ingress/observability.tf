# Phase 6 — Observability on the EKS hub. The OTel collector fans Traefik signals
# out: metrics -> Prometheus and access logs -> Loki (the Grafana stack), traces
# -> Tempo + Langfuse. Every spoke's Traefik ships its OTLP to the hub collector's
# public endpoint (otel.<domain>), so the AI-gateway traces from AKS land in
# Langfuse on the hub — "observability from all components on the EKS cluster".

resource "kubernetes_namespace_v1" "observability" {
  provider = kubernetes.eks
  metadata { name = "traefik-observability" }
}

resource "kubernetes_namespace_v1" "monitoring" {
  provider = kubernetes.eks
  metadata { name = "monitoring" }
}

module "langfuse" {
  source = "../../terraform/observability/langfuse/k8s"
  providers = {
    helm       = helm.eks
    kubernetes = kubernetes.eks
  }

  namespace = kubernetes_namespace_v1.observability.metadata[0].name
  ingress   = false # exposed via the kubectl_manifest IngressRoute below
}

module "opentelemetry" {
  source    = "../../terraform/observability/opentelemetry/k8s"
  providers = { helm = helm.eks }

  namespace = kubernetes_namespace_v1.observability.metadata[0].name

  # Metrics -> exposed on :8889 for the Grafana stack's Prometheus to scrape.
  enable_prometheus = true

  # Access logs -> Loki; traces -> Tempo (Grafana) and the in-cluster Langfuse.
  enable_loki    = true
  loki_endpoint  = "http://loki.${kubernetes_namespace_v1.monitoring.metadata[0].name}.svc.cluster.local:3100/otlp"
  enable_tempo   = true
  tempo_endpoint = "http://tempo.${kubernetes_namespace_v1.monitoring.metadata[0].name}.svc.cluster.local:4318"

  enable_langfuse     = true
  langfuse_endpoint   = module.langfuse.otel_endpoint
  langfuse_public_key = module.langfuse.public_key
  langfuse_secret_key = module.langfuse.secret_key
}

module "grafana_stack" {
  source = "../../terraform/observability/grafana-stack/k8s"
  # No providers block: grafana-stack declares no providers of its own, so it
  # inherits the DEFAULT (EKS) kubernetes/helm providers from providers.tf.

  namespace    = kubernetes_namespace_v1.monitoring.metadata[0].name
  metrics_host = "opentelemetry-opentelemetry-collector.${kubernetes_namespace_v1.observability.metadata[0].name}.svc.cluster.local"
  metrics_port = 8889

  ingress            = true
  ingress_domain     = var.domain
  ingress_entrypoint = "websecure"

  dashboards = {
    aigateway  = true
    mcpgateway = true
    apim       = true
  }

  depends_on = [module.traefik]
}

# Langfuse UI route (agent-native observability for the AI gateway).
resource "kubectl_manifest" "langfuse_route" {
  provider   = kubectl.eks
  depends_on = [module.traefik, module.langfuse]
  yaml_body = yamlencode({
    apiVersion = "traefik.io/v1alpha1"
    kind       = "IngressRoute"
    metadata   = { name = "langfuse-web", namespace = kubernetes_namespace_v1.observability.metadata[0].name }
    spec = {
      entryPoints = ["websecure"]
      routes = [{
        kind     = "Rule"
        match    = "Host(`langfuse.${var.domain}`)"
        services = [{ name = module.langfuse.web_service_name, port = 3000 }]
      }]
    }
  })
}

# Public OTLP endpoint (otel.<domain> -> the collector's OTLP HTTP :4318) so the
# AKS / EC2 / ECS Traefiks can ship their telemetry to the hub collector.
resource "kubectl_manifest" "otel_collector_route" {
  provider   = kubectl.eks
  depends_on = [module.traefik, module.opentelemetry]
  yaml_body = yamlencode({
    apiVersion = "traefik.io/v1alpha1"
    kind       = "IngressRoute"
    metadata   = { name = "otel-collector", namespace = kubernetes_namespace_v1.observability.metadata[0].name }
    spec = {
      entryPoints = ["websecure"]
      routes = [{
        kind     = "Rule"
        match    = "Host(`otel.${var.domain}`)"
        services = [{ name = "opentelemetry-opentelemetry-collector", port = 4318 }]
      }]
    }
  })
}
