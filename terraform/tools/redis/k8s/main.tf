resource "helm_release" "redis" {
  name       = var.name
  namespace  = var.namespace
  repository = "oci://registry-1.docker.io/"
  chart      = "cloudpirates/redis"
  version    = "0.4.6"
  timeout    = 900
  atomic     = true

  values = [
    yamlencode(merge({
      auth = {
        password = var.password
      }
      replica = {
        replicaCount = var.replicaCount
      }
    }, var.extra_values))
  ]
}
