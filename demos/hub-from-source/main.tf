# demos/hub-from-source — run Traefik Hub built from local source on k3d.
#
# Same shape as demos/single-cluster (one cluster + Hub + whoami), but the Hub
# image is swapped for a locally-built one via the traefik/k8s module's
# custom_image_* override. Modelled on the k3d-unified-ingress dev loop:
#
#   make up          # released Hub image — works with just a Hub token
#   make build-hub   # build ../../../traefik-hub -> push to a local k3d registry
#   make up-dev      # re-apply with local_traefik_hub=true (uses the :dev image)
#
# The Hub source itself is NOT bundled here (it's private) — point TRAEFIK_HUB_SRC
# at your checkout. This demo ships the wiring, not the source.

locals {
  # When local_traefik_hub is set, point the module at the image pushed to the
  # local registry by `make build-hub`. A registries.yaml mirror (below) makes
  # the in-cluster reference "localhost:5001/..." resolve to the registry.
  hub_image_registry   = var.local_traefik_hub ? "localhost:5001" : ""
  hub_image_repository = var.local_traefik_hub ? "traefik/traefik-hub" : ""
  hub_image_tag        = var.local_traefik_hub ? "dev" : ""

  registries_yaml = <<-YAML
    mirrors:
      "localhost:5001":
        endpoint:
          - http://${var.registry_name}:5000
  YAML
}

# 1. Cluster. k3d disables its bundled Traefik so the module installs Hub.
#    The local registry is only attached in the from-source path.
module "cluster" {
  source = "../../terraform/compute/suse/k3d"

  cluster_name      = var.cluster_name
  registries_use    = var.local_traefik_hub ? [var.registry_name] : []
  registries_config = var.local_traefik_hub ? local.registries_yaml : ""
}

# 2. Provider wiring — k3d clusters authenticate with a client cert, not a token.
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

# Kubeconfig for the traefik module's CRD local-exec (no current context yet —
# the cluster is created in this same run). Built from the cluster cert outputs.
resource "local_file" "kubeconfig" {
  filename        = "${path.module}/.kubeconfig"
  file_permission = "0600"
  content = yamlencode({
    apiVersion        = "v1"
    kind              = "Config"
    "current-context" = var.cluster_name
    clusters          = [{ name = var.cluster_name, cluster = { server = module.cluster.host, "certificate-authority-data" = base64encode(module.cluster.cluster_ca_certificate) } }]
    users             = [{ name = var.cluster_name, user = { "client-certificate-data" = base64encode(module.cluster.client_certificate), "client-key-data" = base64encode(module.cluster.client_key) } }]
    contexts          = [{ name = var.cluster_name, context = { cluster = var.cluster_name, user = var.cluster_name } }]
  })
}

# 3. Namespaces.
resource "kubernetes_namespace_v1" "traefik" {
  metadata { name = "traefik" }
}

resource "kubernetes_namespace_v1" "apps" {
  metadata { name = "apps" }
}

# 4. Traefik Hub. custom_image_* are empty in the released path (module picks
#    its default image) and point at the local :dev build in the from-source path.
module "traefik" {
  source = "../../terraform/traefik/k8s"

  namespace             = kubernetes_namespace_v1.traefik.metadata[0].name
  traefik_hub_token     = var.traefik_hub_token
  enable_api_gateway    = true
  enable_offline_mode   = true
  dashboard_entrypoints = ["websecure"]
  kubeconfig            = abspath(local_file.kubeconfig.filename)

  custom_image_registry   = local.hub_image_registry
  custom_image_repository = local.hub_image_repository
  custom_image_tag        = local.hub_image_tag
}

# 5. Sample workload to prove ingress works through the from-source Hub.
module "whoami" {
  source = "../../terraform/apps/whoami/k8s"

  # The IngressRoute is a kubectl_manifest; wait for the traefik module to
  # install the traefik.io CRDs first.
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
