resource "kubernetes_deployment_v1" "sqlcl" {
  metadata {
    name      = var.name
    namespace = var.namespace
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = {
        app = "sqlcl-mcp"
      }
    }

    template {
      metadata {
        labels = {
          app = "sqlcl-mcp"
        }
      }

      spec {
        container {
          name  = "sqlcl-mcp"
          image = var.image

          port {
            container_port = var.container_port
          }

          security_context {
            privileged = true
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "sqlcl" {
  metadata {
    name      = var.name
    namespace = var.namespace
  }

  spec {
    selector = {
      app = "sqlcl-mcp"
    }

    port {
      port        = var.service_port
      target_port = var.container_port
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_ingress_v1" "sqlcl-traefik" {
  metadata {
    name      = var.name
    namespace = var.namespace
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

  spec {
    rule {
      host = "sqlcl.${var.ingress_domain}"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = var.name
              port {
                number = var.service_port
              }
            }
          }
        }
      }
    }
  }

  count = var.ingress == true ? 1 : 0
}
