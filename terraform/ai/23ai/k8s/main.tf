resource "kubernetes_stateful_set" "db" {
  metadata {
    name      = var.name
    namespace = var.namespace
  }

  spec {
    service_name = var.name
    replicas     = var.replicas

    selector {
      match_labels = {
        app = "oracle-db"
      }
    }

    template {
      metadata {
        labels = {
          app = "oracle-db"
        }
      }

      spec {
        security_context {
          fs_group = 54321
        }

        init_container {
          name    = "init-permissions"
          image   = "busybox:1.36"
          command = ["sh", "-c", "mkdir -p /opt/oracle/oradata && chown -R 54321:54321 /opt/oracle/oradata"]

          security_context {
            run_as_user = 0
          }

          volume_mount {
            name       = "oracle-db-storage"
            mount_path = "/opt/oracle/oradata"
          }
        }
        container {
          name  = "oracle-db"
          image = var.image

          port {
            container_port = var.container_port
          }

          env {
            name  = "ORACLE_PWD"
            value = var.oracle_pwd
          }

          env {
            name  = "ORACLE_CHARACTERSET"
            value = var.oracle_characterset
          }

          env {
            name  = "ENABLE_ARCHIVELOG"
            value = "true"
          }

          env {
            name  = "ENABLE_FORCE_LOGGING"
            value = "true"
          }

          security_context {
            run_as_user  = 54321
            run_as_group = 54321
          }

          volume_mount {
            name       = "oracle-db-storage"
            mount_path = "/opt/oracle/oradata"
          }
        }
      }
    }

    volume_claim_template {
      metadata {
        name = "oracle-db-storage"
      }
      spec {
        access_modes = ["ReadWriteOnce"]
        resources {
          requests = {
            storage = var.storage_size
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "db" {
  metadata {
    name      = var.name
    namespace = var.namespace
  }

  spec {
    selector = {
      app = "oracle-db"
    }

    port {
      port        = var.service_port
      target_port = var.container_port
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_ingress_v1" "oracle-23ai-traefik" {
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
      host = "oracledb.${var.ingress_domain}"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = var.name
              port {
                number = var.container_port
              }
            }
          }
        }
      }
    }
  }

  count = var.ingress == true ? 1 : 0
}
