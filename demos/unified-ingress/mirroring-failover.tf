# Phase 7 — request mirroring + cross-cluster service-failover on the EKS hub,
# both as Traefik `TraefikService`s.
#
# Mirroring: traffic to mirror.<domain> is served by the hub whoami AND shadow-
# copied to a second whoami (the shadow receives a % of requests out-of-band).
# Failover: traffic to failover.<domain> goes to the AKS spoke; if that leg is
# unhealthy, Traefik fails over to the hub-local whoami.
#
# Asserting the mirror *received* a request, or forcing a failover, is awkward in
# pure curl — scenarios assert the happy-path 200 and the README documents the
# manual checks (scale the primary to 0 -> failover still 200; read the shadow's
# access log to confirm the mirror). The cross-cluster failover primary
# (aks@multicluster) is best-effort and verified live.

# A shadow whoami to receive mirrored traffic.
module "shadow_whoami" {
  source = "../../terraform/apps/whoami/k8s"
  providers = {
    kubernetes = kubernetes.eks
    kubectl    = kubectl.eks
  }

  namespace = local.hub_traefik_ns
  apps = {
    shadow-whoami = { ingress_route = { enabled = false } }
  }
}

resource "kubectl_manifest" "mirror_service" {
  provider   = kubectl.eks
  depends_on = [module.whoami, module.shadow_whoami]
  yaml_body = yamlencode({
    apiVersion = "traefik.io/v1alpha1"
    kind       = "TraefikService"
    metadata   = { name = "whoami-mirror", namespace = local.hub_traefik_ns }
    spec = {
      mirroring = {
        name    = "whoami-svc"
        port    = 80
        mirrors = [{ name = "shadow-whoami-svc", port = 80, percent = 100 }]
      }
    }
  })
}

resource "kubectl_manifest" "mirror_route" {
  provider   = kubectl.eks
  depends_on = [kubectl_manifest.mirror_service]
  yaml_body = yamlencode({
    apiVersion = "traefik.io/v1alpha1"
    kind       = "IngressRoute"
    metadata   = { name = "mirror-whoami", namespace = local.hub_traefik_ns }
    spec = {
      entryPoints = ["websecure"]
      routes = [{
        kind     = "Rule"
        match    = "Host(`mirror.${var.domain}`)"
        services = [{ kind = "TraefikService", name = "whoami-mirror" }]
      }]
    }
  })
}

# Cross-cluster failover: AKS spoke primary, hub-local whoami fallback.
resource "kubectl_manifest" "failover_service" {
  provider   = kubectl.eks
  depends_on = [module.traefik, module.whoami]
  yaml_body = yamlencode({
    apiVersion = "traefik.io/v1alpha1"
    kind       = "TraefikService"
    metadata   = { name = "whoami-failover", namespace = local.hub_traefik_ns }
    spec = {
      failover = {
        service  = { kind = "TraefikService", name = "aks@multicluster" }
        fallback = { name = "whoami-svc", port = 80 }
      }
    }
  })
}

resource "kubectl_manifest" "failover_route" {
  provider   = kubectl.eks
  depends_on = [kubectl_manifest.failover_service]
  yaml_body = yamlencode({
    apiVersion = "traefik.io/v1alpha1"
    kind       = "IngressRoute"
    metadata   = { name = "failover-whoami", namespace = local.hub_traefik_ns }
    spec = {
      entryPoints = ["websecure"]
      routes = [{
        kind     = "Rule"
        match    = "Host(`failover.${var.domain}`)"
        services = [{ kind = "TraefikService", name = "whoami-failover" }]
      }]
    }
  })
}
