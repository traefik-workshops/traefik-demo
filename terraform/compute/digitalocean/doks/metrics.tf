provider "helm" {
  kubernetes = {
    host                   = local.cluster_server
    cluster_ca_certificate = local.cluster_ca_cert
    token                  = local.token
  }
}

resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  version    = "3.12.2"

  namespace = "kube-system"

  depends_on = [null_resource.wait]
}
