# demos/oidc-portal — Traefik Hub API Portal protected by AWS Cognito.

module "vpc" {
  source = "../../terraform/compute/aws/vpc"

  name = var.cluster_name
}

module "cluster" {
  source = "../../terraform/compute/aws/eks"

  cluster_name       = var.cluster_name
  cluster_location   = var.region
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  public_subnet_ids  = module.vpc.public_subnet_ids
  create_vpc         = false
}

module "cognito" {
  source = "../../terraform/security/cognito"

  users         = ["analyst", "admin"]
  redirect_uris = ["https://portal.${var.domain}/callback"]
}

provider "kubernetes" {
  host                   = module.cluster.cluster_endpoint
  cluster_ca_certificate = base64decode(module.cluster.cluster_ca_certificate)
  token                  = module.cluster.token
}

provider "helm" {
  kubernetes = {
    host                   = module.cluster.cluster_endpoint
    cluster_ca_certificate = base64decode(module.cluster.cluster_ca_certificate)
    token                  = module.cluster.token
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
  enable_api_management = true # API Portal lives here
  enable_offline_mode   = true
  dashboard_entrypoints = ["websecure"]
}

module "whoami" {
  source    = "../../terraform/apps/whoami/k8s"
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
