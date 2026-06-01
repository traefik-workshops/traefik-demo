# UC1 — NGINX -> Traefik migration. A workload exposed via a *native* nginx
# Ingress object (ingressClassName: nginx, nginx.ingress.kubernetes.io
# annotations) is served by the hub Traefik unchanged, because the hub runs the
# kubernetesIngressNGINX provider (module.traefik.custom_providers). You migrate
# off ingress-nginx without rewriting a single Ingress — and the incumbent
# controller can keep running side by side during the cutover.

resource "kubernetes_namespace_v1" "legacy" {
  provider = kubernetes.eks
  metadata { name = "legacy" }
}

# The incumbent ingress-nginx controller (coexists; the hub Traefik is the edge LB).
module "nginx" {
  source = "../../terraform/tools/nginx/k8s"
  providers = {
    helm = helm.eks
  }

  namespace = kubernetes_namespace_v1.legacy.metadata[0].name
}

# A legacy workload with NO Traefik IngressRoute — only the nginx Ingress below.
module "legacy_whoami" {
  source = "../../terraform/apps/whoami/k8s"
  providers = {
    kubernetes = kubernetes.eks
    kubectl    = kubectl.eks
  }

  namespace = kubernetes_namespace_v1.legacy.metadata[0].name
  apps = {
    legacy-whoami = {
      ingress_route = { enabled = false }
    }
  }
}

# The existing nginx Ingress. The hub Traefik's kubernetesIngressNGINX provider
# picks it up and serves legacy.<domain> on the websecure entrypoint — the
# migration proof. (dns-traefiker registers *.<domain> at the Traefik LB.)
resource "kubernetes_ingress_v1" "legacy" {
  provider   = kubernetes.eks
  depends_on = [module.traefik, module.legacy_whoami]

  metadata {
    name      = "legacy-whoami"
    namespace = kubernetes_namespace_v1.legacy.metadata[0].name
    annotations = {
      "nginx.ingress.kubernetes.io/rewrite-target" = "/"
    }
  }

  spec {
    ingress_class_name = "nginx"

    rule {
      host = "legacy.${var.domain}"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "legacy-whoami-svc"
              port { number = 80 }
            }
          }
        }
      }
    }
  }
}
