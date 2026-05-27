resource "kubernetes_deployment_v1" "httpbin" {
  metadata {
    name      = "httpbin"
    namespace = "apps"
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "httpbin"
      }
    }
    template {
      metadata {
        labels = {
          app = "httpbin"
        }
      }
      spec {
        container {
          name              = "httpbin"
          image             = "zalbiraw/go-httpbin:latest"
          image_pull_policy = "IfNotPresent"
          port {
            container_port = 8080
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "httpbin" {
  metadata {
    name      = "httpbin-svc"
    namespace = "apps"
  }

  spec {
    selector = {
      app = "httpbin"
    }
    port {
      port        = 8000
      target_port = 8080
    }
  }

  depends_on = [kubernetes_deployment_v1.httpbin]
}
