resource "helm_release" "tempo" {
  name       = var.name
  namespace  = var.namespace
  repository = "https://grafana.github.io/helm-charts"
  chart      = "tempo"
  version    = "1.23.3"
  timeout    = 900
  atomic     = true

  values = [
    yamlencode({
      tempo = {
        reporting_enabled = false
      }
      tempo_query = {
        enabled = true
      }
      tolerations = var.tolerations
    }),
    yamlencode(var.extra_values)
  ]
}
