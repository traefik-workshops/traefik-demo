# demos/oidc-portal — Traefik Hub API Portal protected by AWS Cognito.

module "vpc" {
  source = "git::https://github.com/traefik-workshops/traefik-demo.git//terraform/compute/aws/vpc?ref=v4.0.0"
}

module "cluster" {
  source = "git::https://github.com/traefik-workshops/traefik-demo.git//terraform/compute/aws/eks?ref=v4.0.0"

  cluster_name       = var.cluster_name
  cluster_location   = var.region
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  public_subnet_ids  = module.vpc.public_subnet_ids
  create_vpc         = false
}

module "cognito" {
  source = "git::https://github.com/traefik-workshops/traefik-demo.git//terraform/security/cognito?ref=v4.0.0"

  users         = ["analyst", "admin"]
  redirect_uris = ["https://portal.${var.domain}/callback"]
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

resource "kubernetes_namespace_v1" "traefik" {
  metadata { name = "traefik" }
}
resource "kubernetes_namespace_v1" "apps" {
  metadata { name = "apps" }
}

module "traefik" {
  source = "git::https://github.com/traefik-workshops/traefik-demo.git//terraform/traefik/k8s?ref=v4.0.0"

  namespace             = kubernetes_namespace_v1.traefik.metadata[0].name
  traefik_hub_token     = var.traefik_hub_token
  enable_api_gateway    = true
  enable_api_management = true   # API Portal lives here
  dashboard_entrypoints = ["websecure"]
}

module "whoami" {
  source = "git::https://github.com/traefik-workshops/traefik-demo.git//terraform/apps/whoami/k8s?ref=v4.0.0"
  namespace = kubernetes_namespace_v1.apps.metadata[0].name
  domain    = "whoami.${var.domain}"
}
