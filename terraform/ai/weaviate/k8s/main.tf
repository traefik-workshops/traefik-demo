resource "helm_release" "weaviate" {
  name       = var.name
  namespace  = var.namespace
  repository = "https://weaviate.github.io/weaviate-helm"
  chart      = "weaviate"
  version    = "17.6.1"
  timeout    = 900
  atomic     = true

  values = [yamlencode({
    service = {
      type = "ClusterIP"
    }
    grpcService = {
      enabled = false
    }
  })]
}
