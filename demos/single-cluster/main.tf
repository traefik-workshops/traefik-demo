# demos/single-cluster — one k3d cluster, Traefik Hub, whoami.
#
# The smallest credible demo. Seed for any demo where multicluster + AI + auth
# are not needed.

module "cluster" {
  source       = "../../terraform/compute/suse/k3d"
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

resource "kubernetes_namespace_v1" "traefik" {
  metadata { name = "traefik" }
}

resource "kubernetes_namespace_v1" "apps" {
  metadata { name = "apps" }
}

module "traefik" {
  source = "../../terraform/traefik/k8s"

  namespace             = kubernetes_namespace_v1.traefik.metadata[0].name
  traefik_hub_token     = var.traefik_hub_token
  enable_api_gateway    = true
  enable_offline_mode   = true
  dashboard_entrypoints = ["websecure"]
}

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
