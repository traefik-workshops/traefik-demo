resource "helm_release" "cert_manager" {
  name       = var.name
  namespace  = var.namespace
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "1.18.2"
  timeout    = 900
  atomic     = true

  set = [
    {
      name  = "crds.enabled"
      value = true
    },
    {
      name  = "crds.keep"
      value = false
    }
  ]
}
