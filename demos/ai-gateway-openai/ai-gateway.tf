# AI gateway middlewares + route, as Traefik Hub CRDs. The CRDs are installed
# by the traefik/k8s module (Hub), so everything here depends on it.

locals {
  ns           = kubernetes_namespace_v1.traefik.metadata[0].name
  presidio_url = "http://presidio-analyzer.${local.ns}.svc.cluster.local:3000"
  redis_addr   = "redis.${local.ns}.svc.cluster.local:6379"
}

# Auth injection — sets Authorization: Bearer <key> from the secret.
resource "kubectl_manifest" "openai_cc" {
  depends_on = [module.traefik, kubernetes_secret_v1.ai_provider_keys]
  yaml_body = yamlencode({
    apiVersion = "traefik.io/v1alpha1"
    kind       = "Middleware"
    metadata   = { name = "openai-cc", namespace = local.ns }
    spec = {
      plugin = {
        "chat-completion" = {
          token = "urn:k8s:secret:ai-provider-keys:openai-token"
        }
      }
    }
  })
}

# Regex content-guard — blocks prompts containing an email address.
resource "kubectl_manifest" "content_guard_regex" {
  depends_on = [module.traefik]
  yaml_body = yamlencode({
    apiVersion = "traefik.io/v1alpha1"
    kind       = "Middleware"
    metadata   = { name = "content-guard-regex", namespace = local.ns }
    spec = {
      plugin = {
        "content-guard" = {
          clientRequestFormat = "ccr"
          engine              = { regex = {} }
          request = {
            rules = [{
              reason   = "email_detected"
              block    = true
              entities = ["[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}"]
            }]
            onDenyResponse = {
              statusCode = 200
              message    = "Request blocked: an email address was detected in the prompt. Rephrase without email addresses."
            }
          }
        }
      }
    }
  })
}

# Presidio content-guard — blocks credit card / SSN (deterministic recognizers,
# so this works on released Hub) and masks them on the response.
resource "kubectl_manifest" "content_guard_presidio" {
  depends_on = [module.traefik, module.presidio]
  yaml_body = yamlencode({
    apiVersion = "traefik.io/v1alpha1"
    kind       = "Middleware"
    metadata   = { name = "content-guard-presidio", namespace = local.ns }
    spec = {
      plugin = {
        "content-guard" = {
          clientRequestFormat = "ccr"
          engine = {
            presidio = {
              host     = local.presidio_url
              language = "en"
            }
          }
          request = {
            rules = [{
              reason   = "pii_detected"
              block    = true
              entities = ["CREDIT_CARD", "US_SSN"]
            }]
            onDenyResponse = {
              statusCode = 200
              message    = "Request blocked: a credit card or SSN was detected in the prompt. Rephrase without sensitive data."
            }
          }
          response = {
            rules = [{
              entities = ["CREDIT_CARD", "US_SSN"]
              mask     = { char = "#", unmaskFromRight = 4 }
            }]
          }
        }
      }
    }
  })
}

# Token rate-limit — Redis-backed sliding window over response token usage.
resource "kubectl_manifest" "ai_rate_limit" {
  depends_on = [module.traefik, kubernetes_service_v1.redis]
  yaml_body = yamlencode({
    apiVersion = "traefik.io/v1alpha1"
    kind       = "Middleware"
    metadata   = { name = "ai-rate-limit", namespace = local.ns }
    spec = {
      plugin = {
        "ai-rate-limit" = {
          store = {
            redis = { endpoints = [local.redis_addr] }
          }
          totalTokenLimit = {
            limit     = var.token_limit
            period    = "1h"
            jsonQuery = ".usage.total_tokens"
          }
        }
      }
    }
  })
}

# Chain — guards first, then rate-limit, then auth injection (the auth plugin
# consumes the body, so guards must run before it).
resource "kubectl_manifest" "ai_pipeline" {
  depends_on = [
    kubectl_manifest.content_guard_regex,
    kubectl_manifest.content_guard_presidio,
    kubectl_manifest.ai_rate_limit,
    kubectl_manifest.openai_cc,
  ]
  yaml_body = yamlencode({
    apiVersion = "traefik.io/v1alpha1"
    kind       = "Middleware"
    metadata   = { name = "ai-pipeline", namespace = local.ns }
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

# Route — /v1/chat/completions through the chain to the upstream.
resource "kubectl_manifest" "ai_chat_completions" {
  depends_on = [kubectl_manifest.ai_pipeline, kubernetes_service_v1.openai_external]
  yaml_body = yamlencode({
    apiVersion = "traefik.io/v1alpha1"
    kind       = "IngressRoute"
    metadata   = { name = "ai-chat-completions", namespace = local.ns }
    spec = {
      entryPoints = ["web"]
      routes = [{
        kind        = "Rule"
        match       = "Host(`ai.${var.domain}`) && PathPrefix(`/v1/chat/completions`)"
        middlewares = [{ name = "ai-pipeline" }]
        services = [{
          name           = "openai-external"
          port           = 443
          scheme         = "https"
          passHostHeader = false
        }]
      }]
    }
  })
}
