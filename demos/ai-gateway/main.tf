# demos/ai-gateway — AI gateway with shared middlewares (Presidio, Weaviate
# semantic cache via Embeddings), an in-cluster model backend (Ollama), and
# Keycloak for OIDC. CPU-only — does not require GPU.

module "cluster" {
  source = "../../terraform/compute/digitalocean/doks"

  cluster_name       = var.cluster_name
  cluster_location   = var.cluster_location
  cluster_node_count = 3 # Helm AI gateway pulls weaviate + presidio + embeddings
}

provider "kubernetes" {
  host                   = module.cluster.host
  cluster_ca_certificate = base64decode(module.cluster.cluster_ca_certificate)
  token                  = module.cluster.token
}

provider "helm" {
  kubernetes = {
    host                   = module.cluster.host
    cluster_ca_certificate = base64decode(module.cluster.cluster_ca_certificate)
    token                  = module.cluster.token
  }
}

# Namespaces.
resource "kubernetes_namespace_v1" "traefik" {
  metadata { name = "traefik" }
}
resource "kubernetes_namespace_v1" "ai" {
  metadata { name = "ai" }
}
resource "kubernetes_namespace_v1" "auth" {
  metadata { name = "auth" }
}

# Traefik Hub with AI gateway features enabled.
module "traefik" {
  source = "../../terraform/traefik/k8s"

  namespace             = kubernetes_namespace_v1.traefik.metadata[0].name
  traefik_hub_token     = var.traefik_hub_token
  enable_api_gateway    = true
  enable_ai_gateway     = true
  enable_mcp_gateway    = true
  dashboard_entrypoints = ["websecure"]
}

# Keycloak — OIDC for the AI gateway.
module "keycloak" {
  source = "../../terraform/security/keycloak/k8s"

  namespace = kubernetes_namespace_v1.auth.metadata[0].name
  users     = []
  advanced_users = [
    { username = "analyst", email = "analyst@example.com", password = var.demo_user_password, groups = ["analyst"], claims = {} },
  ]
  ingress = {
    enabled    = true
    domain     = var.domain
    entrypoint = "websecure"
  }
}

# Ollama — in-cluster CPU model backend.
module "ollama" {
  source = "../../terraform/ai/ollama/k8s"

  namespace    = kubernetes_namespace_v1.ai.metadata[0].name
  enable_llama = true # small model for CPU
}
