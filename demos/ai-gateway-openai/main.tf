# demos/ai-gateway-openai — Traefik Hub AI Gateway in front of an
# OpenAI-compatible API, with content-guards (regex + Presidio) and a
# token rate-limit. White-labeled from clients/Mercury.
#
# The gateway:
#   - injects the upstream key (chat-completion middleware)
#   - blocks prompts containing an email (regex guard)
#   - blocks prompts containing a credit card / SSN (Presidio guard) and
#     masks them on the way back
#   - caps token usage (ai-rate-limit, Redis-backed)
#
# Guard rejections happen at the gateway, so those scenarios run without a
# real key or backend. Only the happy path needs a real key (or a mock).

module "cluster" {
  source = "../../terraform/compute/suse/k3d"

  cluster_name = var.cluster_name
}

provider "k3d" {}

provider "kubernetes" {
  host                   = module.cluster.host
  client_certificate     = module.cluster.client_certificate
  client_key             = module.cluster.client_key
  cluster_ca_certificate = module.cluster.cluster_ca_certificate
}

provider "helm" {
  kubernetes = {
    host                   = module.cluster.host
    client_certificate     = module.cluster.client_certificate
    client_key             = module.cluster.client_key
    cluster_ca_certificate = module.cluster.cluster_ca_certificate
  }
}

provider "kubectl" {
  host                   = module.cluster.host
  client_certificate     = module.cluster.client_certificate
  client_key             = module.cluster.client_key
  cluster_ca_certificate = module.cluster.cluster_ca_certificate
  load_config_file       = false
}

resource "kubernetes_namespace_v1" "traefik" {
  metadata { name = "traefik" }
}

# Traefik Hub with the AI gateway enabled.
module "traefik" {
  source = "../../terraform/traefik/k8s"

  namespace          = kubernetes_namespace_v1.traefik.metadata[0].name
  traefik_hub_token  = var.traefik_hub_token
  enable_api_gateway = true
  enable_ai_gateway  = true
}

# Presidio analyzer — the PII engine the content-guard calls.
# Service name "presidio-analyzer" matches the middleware host below.
module "presidio" {
  source = "../../terraform/ai/presidio/k8s"

  name      = "presidio-analyzer"
  namespace = kubernetes_namespace_v1.traefik.metadata[0].name
}

# Redis — backs the token rate-limit. Auth-less for the demo.
resource "kubernetes_deployment_v1" "redis" {
  metadata {
    name      = "redis"
    namespace = kubernetes_namespace_v1.traefik.metadata[0].name
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

resource "kubernetes_service_v1" "redis" {
  metadata {
    name      = "redis"
    namespace = kubernetes_namespace_v1.traefik.metadata[0].name
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
resource "kubernetes_secret_v1" "ai_provider_keys" {
  metadata {
    name      = "ai-provider-keys"
    namespace = kubernetes_namespace_v1.traefik.metadata[0].name
  }
  data = {
    openai-token = var.openai_api_key
  }
}

# Upstream backend. ExternalName so SNI + Host resolve to the OpenAI-compatible
# host; passHostHeader=false on the route keeps the Host correct.
resource "kubernetes_service_v1" "openai_external" {
  metadata {
    name      = "openai-external"
    namespace = kubernetes_namespace_v1.traefik.metadata[0].name
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
