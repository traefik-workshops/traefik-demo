# demos/single-cluster — one cluster, Traefik Hub, whoami.
#
# The smallest credible demo. Use this as the seed for every demo where
# multicluster + AI + auth are not needed.

# 1. Cluster. Swap the source for any compute/<cloud> module.
module "cluster" {
  source = "../../terraform/compute/digitalocean/doks"

  cluster_name     = var.cluster_name
  cluster_location = var.cluster_location
}

# 2. Provider wiring — every subsequent module talks to this cluster.
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

# 3. Namespaces.
resource "kubernetes_namespace_v1" "traefik" {
  metadata { name = "traefik" }
}

resource "kubernetes_namespace_v1" "apps" {
  metadata { name = "apps" }
}

# 4. Traefik Hub.
module "traefik" {
  source = "../../terraform/traefik/k8s"

  namespace             = kubernetes_namespace_v1.traefik.metadata[0].name
  traefik_hub_token     = var.traefik_hub_token
  enable_api_gateway    = true
  dashboard_entrypoints = ["websecure"]
}

# 5. Sample workload to prove ingress works.
module "whoami" {
  source = "../../terraform/apps/whoami/k8s"

  namespace = kubernetes_namespace_v1.apps.metadata[0].name
  apps = {
    whoami = {
      ingress_route = {
        enabled     = true
        host        = "whoami.${var.domain}"
        entrypoints = ["websecure"]
      }
    }
  }
}
