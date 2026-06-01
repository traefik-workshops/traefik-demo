# Providers. Each cluster gets its own aliased kubernetes/helm/kubectl set so the
# multi-cloud mesh (EKS hub + AKS spoke, layered in later phases) wires cleanly.
# The EKS hub authenticates with the cluster bearer token from the module output.

provider "aws" {
  region = var.region
}

provider "kubernetes" {
  alias                  = "eks"
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = module.eks.cluster_ca_certificate
  token                  = module.eks.token
}

provider "helm" {
  alias = "eks"
  kubernetes = {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = module.eks.cluster_ca_certificate
    token                  = module.eks.token
  }
}

provider "kubectl" {
  alias                  = "eks"
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = module.eks.cluster_ca_certificate
  token                  = module.eks.token
  load_config_file       = false
}

# DEFAULT kubernetes + helm providers, pointing at the EKS hub (same as the .eks
# aliases). These exist only for pass-through wrapper modules that declare no
# providers of their own (e.g. grafana-stack) and so can't take an explicit
# providers block — they inherit these. Every other module uses an explicit
# .eks / .aks alias.
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = module.eks.cluster_ca_certificate
  token                  = module.eks.token
}

provider "helm" {
  kubernetes = {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = module.eks.cluster_ca_certificate
    token                  = module.eks.token
  }
}

# Kubeconfig for the hub traefik module's CRD install (a local-exec kubectl). The
# cluster is created in this same run, so there's no current context — build one
# from the EKS endpoint + CA + token (same trick as the other cloud demos).
resource "local_file" "eks_kubeconfig" {
  filename        = "${path.module}/.eks.kubeconfig"
  file_permission = "0600"
  content = yamlencode({
    apiVersion        = "v1"
    kind              = "Config"
    "current-context" = "eks"
    clusters          = [{ name = "eks", cluster = { server = module.eks.cluster_endpoint, "certificate-authority-data" = base64encode(module.eks.cluster_ca_certificate) } }]
    users             = [{ name = "eks", user = { token = module.eks.token } }]
    contexts          = [{ name = "eks", context = { cluster = "eks", user = "eks" } }]
  })
}
