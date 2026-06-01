# Phase 3 — AI + MCP gateway on the AKS spoke. The content-guard + token-limit
# chain (the ai-gateway-openai shape) runs on the AKS Traefik; the EKS hub fronts
# it at ai.<domain> over a dedicated multicluster uplink (aks-ai). MCP inspector
# is fronted at mcp.<domain> over aks-mcp. Guard rejections happen at the gateway,
# so the block scenarios need no real key. (Traces -> Langfuse on the hub: Phase 6.)

locals {
  aks_ns           = kubernetes_namespace_v1.aks_traefik.metadata[0].name
  aks_presidio_url = "http://presidio-analyzer.${local.aks_ns}.svc.cluster.local:3000"
  aks_redis_addr   = "redis.${local.aks_ns}.svc.cluster.local:6379"
}

# Presidio analyzer — the PII engine the content-guard calls (kubernetes-only module).
module "aks_presidio" {
  source    = "../../terraform/ai/presidio/k8s"
  providers = { kubernetes = kubernetes.aks }

  name      = "presidio-analyzer"
  namespace = local.aks_ns
}

# Redis — backs the token rate-limit.
resource "kubernetes_deployment_v1" "aks_redis" {
  provider = kubernetes.aks
  metadata {
    name      = "redis"
    namespace = local.aks_ns
    labels    = { app = "redis" }
  }
  spec {
    replicas = 1
    selector { match_labels = { app = "redis" } }
    template {
      metadata { labels = { app = "redis" } }
      spec {
        container {
          name  = "redis"
          image = "redis:7-alpine"
          port { container_port = 6379 }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "aks_redis" {
  provider = kubernetes.aks
  metadata {
    name      = "redis"
    namespace = local.aks_ns
  }
  spec {
    selector = { app = "redis" }
    port {
      port        = 6379
      target_port = 6379
    }
  }
}

# Upstream key the chat-completion middleware injects.
resource "kubernetes_secret_v1" "aks_ai_provider_keys" {
  provider = kubernetes.aks
  metadata {
    name      = "ai-provider-keys"
    namespace = local.aks_ns
  }
  data = { openai-token = var.openai_api_key }
}

# Upstream backend (OpenAI-compatible). ExternalName; passHostHeader=false on the route.
resource "kubernetes_service_v1" "aks_openai_external" {
  provider = kubernetes.aks
  metadata {
    name      = "openai-external"
    namespace = local.aks_ns
  }
  spec {
    type          = "ExternalName"
    external_name = var.backend_external_name
    port {
      name        = "https"
      port        = 443
      target_port = 443
      protocol    = "TCP"
    }
  }
}

# --- AI middleware chain (Hub CRDs on AKS) -----------------------------------
resource "kubectl_manifest" "aks_openai_cc" {
  provider   = kubectl.aks
  depends_on = [module.aks_traefik, kubernetes_secret_v1.aks_ai_provider_keys]
  yaml_body = yamlencode({
    apiVersion = "traefik.io/v1alpha1"
    kind       = "Middleware"
    metadata   = { name = "openai-cc", namespace = local.aks_ns }
    spec = {
      plugin = { "chat-completion" = { token = "urn:k8s:secret:ai-provider-keys:openai-token" } }
    }
  })
}

resource "kubectl_manifest" "aks_content_guard_regex" {
  provider   = kubectl.aks
  depends_on = [module.aks_traefik]
  yaml_body = yamlencode({
    apiVersion = "traefik.io/v1alpha1"
    kind       = "Middleware"
    metadata   = { name = "content-guard-regex", namespace = local.aks_ns }
    spec = {
      plugin = {
        "content-guard" = {
          clientRequestFormat = "ccr"
          engine              = { regex = {} }
          request = {
            rules          = [{ reason = "email_detected", block = true, entities = ["[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}"] }]
            onDenyResponse = { statusCode = 200, message = "Request blocked: an email address was detected in the prompt." }
          }
        }
      }
    }
  })
}

resource "kubectl_manifest" "aks_content_guard_presidio" {
  provider   = kubectl.aks
  depends_on = [module.aks_traefik, module.aks_presidio]
  yaml_body = yamlencode({
    apiVersion = "traefik.io/v1alpha1"
    kind       = "Middleware"
    metadata   = { name = "content-guard-presidio", namespace = local.aks_ns }
    spec = {
      plugin = {
        "content-guard" = {
          clientRequestFormat = "ccr"
          engine              = { presidio = { host = local.aks_presidio_url, language = "en" } }
          request = {
            rules          = [{ reason = "pii_detected", block = true, entities = ["CREDIT_CARD", "US_SSN"] }]
            onDenyResponse = { statusCode = 200, message = "Request blocked: a credit card or SSN was detected in the prompt." }
          }
          response = {
            rules = [{ entities = ["CREDIT_CARD", "US_SSN"], mask = { char = "#", unmaskFromRight = 4 } }]
          }
        }
      }
    }
  })
}

resource "kubectl_manifest" "aks_ai_rate_limit" {
  provider   = kubectl.aks
  depends_on = [module.aks_traefik, kubernetes_service_v1.aks_redis]
  yaml_body = yamlencode({
    apiVersion = "traefik.io/v1alpha1"
    kind       = "Middleware"
    metadata   = { name = "ai-rate-limit", namespace = local.aks_ns }
    spec = {
      plugin = {
        "ai-rate-limit" = {
          store           = { redis = { endpoints = [local.aks_redis_addr] } }
          totalTokenLimit = { limit = var.token_limit, period = "1h", jsonQuery = ".usage.total_tokens" }
        }
      }
    }
  })
}

resource "kubectl_manifest" "aks_ai_pipeline" {
  provider = kubectl.aks
  depends_on = [
    kubectl_manifest.aks_content_guard_regex,
    kubectl_manifest.aks_content_guard_presidio,
    kubectl_manifest.aks_ai_rate_limit,
    kubectl_manifest.aks_openai_cc,
  ]
  yaml_body = yamlencode({
    apiVersion = "traefik.io/v1alpha1"
    kind       = "Middleware"
    metadata   = { name = "ai-pipeline", namespace = local.aks_ns }
    spec = {
      chain = {
        middlewares = [
          { name = "content-guard-regex" },
          { name = "content-guard-presidio" },
          { name = "ai-rate-limit" },
          { name = "openai-cc" },
        ]
      }
    }
  })
}

# Advertise the AI gateway over a dedicated uplink (aks-ai). The EKS hub routes
# Host(ai.<domain>) -> aks-ai@multicluster (routes.tf); the child matches the path.
resource "kubectl_manifest" "aks_ai_uplink" {
  provider   = kubectl.aks
  depends_on = [module.aks_traefik]
  yaml_body = yamlencode({
    apiVersion = "hub.traefik.io/v1alpha1"
    kind       = "Uplink"
    metadata   = { name = "aks-ai", namespace = local.aks_ns }
    spec       = { exposeName = "aks-ai" }
  })
}

resource "kubectl_manifest" "aks_ai_route" {
  provider   = kubectl.aks
  depends_on = [kubectl_manifest.aks_ai_pipeline, kubernetes_service_v1.aks_openai_external, kubectl_manifest.aks_ai_uplink]
  yaml_body = yamlencode({
    apiVersion = "traefik.io/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      name        = "ai-chat-completions"
      namespace   = local.aks_ns
      annotations = { "hub.traefik.io/router.uplinks" = "aks-ai" }
    }
    spec = {
      # Uplink mode: no entryPoints (Host owned by the parent route); match the path.
      routes = [{
        kind        = "Rule"
        match       = "PathPrefix(`/v1/chat/completions`)"
        middlewares = [{ name = "ai-pipeline" }]
        services    = [{ name = "openai-external", port = 443, scheme = "https", passHostHeader = false }]
      }]
    }
  })
}

# --- MCP gateway: mcp-inspector test client, fronted at mcp.<domain> ----------
module "aks_mcp_inspector" {
  source    = "../../terraform/tools/mcp-inspector/k8s"
  providers = { kubernetes = kubernetes.aks }

  namespace = local.aks_ns
}

resource "kubectl_manifest" "aks_mcp_uplink" {
  provider   = kubectl.aks
  depends_on = [module.aks_traefik]
  yaml_body = yamlencode({
    apiVersion = "hub.traefik.io/v1alpha1"
    kind       = "Uplink"
    metadata   = { name = "aks-mcp", namespace = local.aks_ns }
    spec       = { exposeName = "aks-mcp" }
  })
}

resource "kubectl_manifest" "aks_mcp_route" {
  provider   = kubectl.aks
  depends_on = [module.aks_mcp_inspector, kubectl_manifest.aks_mcp_uplink]
  yaml_body = yamlencode({
    apiVersion = "traefik.io/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      name        = "mcp-inspector"
      namespace   = local.aks_ns
      annotations = { "hub.traefik.io/router.uplinks" = "aks-mcp" }
    }
    spec = {
      routes = [{
        kind     = "Rule"
        match    = "PathPrefix(`/`)"
        services = [{ name = "mcp-inspector", port = 6274 }]
      }]
    }
  })
}
