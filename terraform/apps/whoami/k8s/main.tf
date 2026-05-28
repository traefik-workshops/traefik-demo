# Create Kubernetes deployments for each app
resource "kubernetes_deployment_v1" "echo" {
  for_each = var.apps

  metadata {
    name      = each.key
    namespace = var.namespace
    labels = merge(
      var.common_labels,
      each.value.labels,
      {
        app = each.key
      }
    )
  }

  spec {
    replicas = each.value.replicas

    selector {
      match_labels = {
        app = each.key
      }
    }

    template {
      metadata {
        labels = merge(
          var.common_labels,
          each.value.labels,
          {
            app = each.key
          }
        )
      }

      spec {
        node_selector = var.node_selector

        container {
          name              = each.key
          image             = each.value.docker_image
          image_pull_policy = "IfNotPresent"

          port {
            container_port = each.value.port
          }

          env {
            name  = "WHOAMI_NAME"
            value = each.key
          }

          env {
            name = "POD_NAME"
            value_from {
              field_ref {
                field_path = "metadata.name"
              }
            }
          }

          env {
            name = "POD_IP"
            value_from {
              field_ref {
                field_path = "status.podIP"
              }
            }
          }

          env {
            name  = "REPLICA_NUMBER"
            value = "k8s-managed"
          }
        }
      }
    }
  }
}

# Create Kubernetes services for each app
resource "kubernetes_service_v1" "echo" {
  for_each = var.apps

  metadata {
    name      = "${each.key}-svc"
    namespace = var.namespace
    labels = merge(
      var.common_labels,
      each.value.labels,
      {
        app = each.key
      }
    )
  }

  spec {
    type = "ClusterIP"

    selector = {
      app = each.key
    }

    port {
      port        = each.value.port
      target_port = each.value.port
    }
  }

  depends_on = [kubernetes_deployment_v1.echo]
}

resource "kubectl_manifest" "middleware_strip_prefix" {
  for_each = {
    for k, v in var.apps : k => v
    if v.ingress_route.enabled && v.ingress_route.strip_prefix.enabled
  }

  yaml_body = yamlencode({
    apiVersion = "traefik.io/v1alpha1"
    kind       = "Middleware"
    metadata = {
      name      = "${each.key}-strip-prefix"
      namespace = var.namespace
    }
    spec = {
      stripPrefix = {
        prefixes = each.value.ingress_route.strip_prefix.prefixes
      }
    }
  })
}

resource "kubectl_manifest" "uplink" {
  count = var.uplink_enabled ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "hub.traefik.io/v1alpha1"
    kind       = "Uplink"
    metadata = {
      name      = "whoami"
      namespace = var.namespace
    }
    spec = {
      exposeName = "whoami"
    }
  })
}

resource "kubectl_manifest" "ingress_route" {
  for_each = {
    for k, v in var.apps : k => v
    if v.ingress_route.enabled
  }

  yaml_body = yamlencode({
    apiVersion = "traefik.io/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      name      = "${each.key}-ingress-route"
      namespace = var.namespace
      annotations = merge(
        var.uplink_enabled ? { "hub.traefik.io/router.uplinks" = "whoami" } : {},
        var.ingress_observability ? {} : {
          "traefik.ingress.kubernetes.io/router.observability.accesslogs" = "false"
          "traefik.ingress.kubernetes.io/router.observability.metrics"    = "false"
          "traefik.ingress.kubernetes.io/router.observability.tracing"    = "false"
        },
        var.ingress_annotations,
      )
    }
    spec = {
      entryPoints = var.uplink_enabled ? [] : each.value.ingress_route.entrypoints
      routes = [
        {
          match = join(" && ", compact([
            each.value.ingress_route.host != null && each.value.ingress_route.host != "" ? "Host(`${each.value.ingress_route.host}`)" : "",
            each.value.ingress_route.strip_prefix.enabled && length(each.value.ingress_route.strip_prefix.prefixes) > 0 ? "PathPrefix(`${join("`, `", each.value.ingress_route.strip_prefix.prefixes)}`)" : ""
          ]))
          kind = "Rule"
          middlewares = concat(
            [for m in each.value.ingress_route.middlewares : {
              name      = m.name
              namespace = try(m.namespace, var.namespace)
            }],
            each.value.ingress_route.strip_prefix.enabled ? [{
              name      = "${each.key}-strip-prefix"
              namespace = var.namespace
            }] : []
          )
          services = [
            {
              name = "${each.key}-svc"
              port = each.value.port
            }
          ]
        }
      ]
    }
  })
}
