resource "helm_release" "k6_operator" {
  name       = var.name
  namespace  = var.namespace
  repository = "https://grafana.github.io/helm-charts"
  chart      = "k6-operator"
  version    = "4.0.0"
  timeout    = 900
  atomic     = true

  values = [yamlencode(merge({
    installCRDs = true
    namespace = {
      create = false
    }
    nodeSelector = var.node_selector
    tolerations  = var.tolerations
    manager = {
      resources = {}
    }
  }, var.extra_values))]
}
