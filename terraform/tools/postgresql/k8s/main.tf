resource "helm_release" "postgres" {
  name       = var.name
  namespace  = var.namespace
  repository = "oci://registry-1.docker.io/"
  chart      = "cloudpirates/postgres"
  version    = "0.6.1"
  timeout    = 900
  atomic     = true

  values = [
    yamlencode(merge({
      auth = {
        database = var.database
        password = var.password
      }
      persistentVolumeClaimRetentionPolicy = {
        enabled     = true
        whenDeleted = "Delete"
      }
    }, var.extra_values))
  ]
}
