resource "kubernetes_deployment_v1" "presidio" {
  metadata {
    name      = var.name
    namespace = var.namespace
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "presidio"
      }
    }
    template {
      metadata {
        labels = {
          app = "presidio"
        }
      }
      spec {
        container {
          name  = "presidio"
          image = "mcr.microsoft.com/presidio-analyzer:2.2.358"
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "presidio" {
  metadata {
    name      = var.name
    namespace = var.namespace
  }
  spec {
    type = "ClusterIP"
    port {
      port = 3000
      name = "presidio"
    }
    selector = {
      app = "presidio"
    }
  }

  depends_on = [kubernetes_deployment_v1.presidio]
}
