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

# Used by the whoami module's IngressRoute (a kubectl_manifest).
provider "kubectl" {
  host                   = module.cluster.host
  client_certificate     = module.cluster.client_certificate
  client_key             = module.cluster.client_key
  cluster_ca_certificate = module.cluster.cluster_ca_certificate
  load_config_file       = false
}

# The traefik module installs CRDs via a local-exec kubectl, which needs a
# kubeconfig — the cluster is created in this same run, so there's no current
# context. Build one from the cluster's cert outputs.
locals {
  kubeconfig = yamlencode({
    apiVersion        = "v1"
    kind              = "Config"
    "current-context" = var.cluster_name
    clusters          = [{ name = var.cluster_name, cluster = { server = module.cluster.host, "certificate-authority-data" = base64encode(module.cluster.cluster_ca_certificate) } }]
    users             = [{ name = var.cluster_name, user = { "client-certificate-data" = base64encode(module.cluster.client_certificate), "client-key-data" = base64encode(module.cluster.client_key) } }]
    contexts          = [{ name = var.cluster_name, context = { cluster = var.cluster_name, user = var.cluster_name } }]
  })
}

resource "local_file" "kubeconfig" {
  content         = local.kubeconfig
  filename        = "${path.module}/.kubeconfig"
  file_permission = "0600"
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
  kubeconfig            = abspath(local_file.kubeconfig.filename)
}

module "whoami" {
  source = "../../terraform/apps/whoami/k8s"

  # The IngressRoute is a kubectl_manifest — the traefik module installs its CRD,
  # so wait for it (a fresh cluster has no traefik.io CRDs until then).
  depends_on = [module.traefik]

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
