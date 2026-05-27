locals {
  argocd_password_hash = bcrypt(var.admin_password)
}

resource "helm_release" "argocd" {
  name       = var.name
  namespace  = var.namespace
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "9.1.5"
  timeout    = 900
  atomic     = true

  set = [
    {
      name  = "server.service.type"
      value = "ClusterIP"
    },
    {
      name  = "server.extraArgs"
      value = "{--insecure}"
    },
    {
      name  = "configs.params.server\\.insecure"
      value = "true"
    },
    {
      name  = "crds.keep"
      value = false
    }
  ]

  set_sensitive = [
    {
      name  = "configs.secret.argocdServerAdminPassword"
      value = local.argocd_password_hash
    }
  ]

  lifecycle {
    ignore_changes = [set_sensitive]
  }
}

resource "kubernetes_ingress_v1" "argocd-traefik" {
  metadata {
    name      = "argocd"
    namespace = "traefik-tools"
    annotations = merge(
      { "traefik.ingress.kubernetes.io/router.entrypoints" = var.ingress_entrypoint },
      var.ingress_observability ? {} : {
        "traefik.ingress.kubernetes.io/router.observability.accesslogs" = "false"
        "traefik.ingress.kubernetes.io/router.observability.metrics"    = "false"
        "traefik.ingress.kubernetes.io/router.observability.tracing"    = "false"
      },
      var.ingress_annotations,
    )
  }

  dynamic "spec" {
    for_each = var.ingress ? ["argocd"] : []
    content {
      rule {
        host = "argocd.${var.ingress_domain}"
        http {
          path {
            path      = "/"
            path_type = "Prefix"
            backend {
              service {
                name = "argocd-server"
                port {
                  number = 80
                }
              }
            }
          }
        }
      }
    }
  }

  count      = var.ingress ? 1 : 0
  depends_on = [helm_release.argocd]
}
