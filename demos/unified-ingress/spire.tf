# Phase 2c — SPIFFE mTLS on the multicluster uplink. Per-cluster SPIRE trust
# domains (federated) issue an SVID to each Traefik; the EKS hub then verifies
# the AKS child's SVID via serversTransport.spiffe (main.tf), replacing
# insecureSkipVerify.
#
# CAVEAT — the cross-cloud federation specifics below (the spire-server-federation
# service name/port, the bundle-endpoint path, https_web bootstrap, and whether
# the child uplink entrypoint presents its SVID from the global --spiffe config or
# needs an extra arg) are best-effort and VERIFIED ON A LIVE APPLY. The offline
# gate only checks that the manifests are well-formed. See PLAN.md.

locals {
  eks_trust_domain = "eks.unified-ingress"
  aks_trust_domain = "aks.unified-ingress"

  # The SVID each cluster's Traefik receives (ns/traefik, sa/traefik via the
  # ClusterSPIFFEID template below). The hub pins the AKS id in its uplink
  # serversTransport.spiffe.ids; symmetric for the AKS child.
  eks_traefik_spiffe_id = "spiffe://${local.eks_trust_domain}/ns/traefik/sa/traefik"
  aks_traefik_spiffe_id = "spiffe://${local.aks_trust_domain}/ns/traefik/sa/traefik"

  # In-pod Workload API socket the spiffe-csi-driver mounts; both Traefiks read it.
  spiffe_workload_api_arg = "--spiffe.workloadAPIAddress=unix://${module.spire_eks.workload_api_socket_path}"
  spiffe_volumes = [{
    name = "spiffe-workload-api"
    csi  = { driver = "csi.spiffe.io", readOnly = true }
  }]
  spiffe_volume_mounts = [{
    name      = "spiffe-workload-api"
    mountPath = "/spiffe-workload-api"
    readOnly  = true
  }]
}

module "spire_eks" {
  source = "../../terraform/security/spire/k8s"
  providers = {
    helm       = helm.eks
    kubernetes = kubernetes.eks
  }

  trust_domain      = local.eks_trust_domain
  cluster_name      = "eks-hub"
  enable_federation = true
}

module "spire_aks" {
  source = "../../terraform/security/spire/k8s"
  providers = {
    helm       = helm.aks
    kubernetes = kubernetes.aks
  }

  trust_domain      = local.aks_trust_domain
  cluster_name      = "aks-spoke"
  enable_federation = true
}

# Register each Traefik as a SPIRE workload so it gets an SVID. The pod reads the
# Workload API over the CSI socket (the spiffe volumes on each traefik module).
resource "kubectl_manifest" "spiffeid_eks_traefik" {
  provider   = kubectl.eks
  depends_on = [module.spire_eks]
  yaml_body = yamlencode({
    apiVersion = "spire.spiffe.io/v1alpha1"
    kind       = "ClusterSPIFFEID"
    metadata   = { name = "traefik-eks" }
    spec = {
      spiffeIDTemplate = "spiffe://{{ .TrustDomain }}/ns/{{ .PodMeta.Namespace }}/sa/{{ .PodSpec.ServiceAccountName }}"
      podSelector      = { matchLabels = { "app.kubernetes.io/name" = "traefik" } }
    }
  })
}

resource "kubectl_manifest" "spiffeid_aks_traefik" {
  provider   = kubectl.aks
  depends_on = [module.spire_aks]
  yaml_body = yamlencode({
    apiVersion = "spire.spiffe.io/v1alpha1"
    kind       = "ClusterSPIFFEID"
    metadata   = { name = "traefik-aks" }
    spec = {
      spiffeIDTemplate = "spiffe://{{ .TrustDomain }}/ns/{{ .PodMeta.Namespace }}/sa/{{ .PodSpec.ServiceAccountName }}"
      podSelector      = { matchLabels = { "app.kubernetes.io/name" = "traefik" } }
    }
  })
}

# Cross-cloud federation: each cluster trusts the peer's bundle, fetched from the
# peer's federation bundle endpoint (exposed below over the peer Traefik's
# websecure entrypoint, so it carries a Let's Encrypt cert — https_web, no manual
# bundle bootstrap).
resource "kubectl_manifest" "federate_eks_to_aks" {
  provider   = kubectl.eks
  depends_on = [module.spire_eks]
  yaml_body = yamlencode({
    apiVersion = "spire.spiffe.io/v1alpha1"
    kind       = "ClusterFederatedTrustDomain"
    metadata   = { name = "aks" }
    spec = {
      trustDomain           = local.aks_trust_domain
      bundleEndpointURL     = "https://spire-aks.${var.domain}"
      bundleEndpointProfile = { type = "https_web" }
    }
  })
}

resource "kubectl_manifest" "federate_aks_to_eks" {
  provider   = kubectl.aks
  depends_on = [module.spire_aks]
  yaml_body = yamlencode({
    apiVersion = "spire.spiffe.io/v1alpha1"
    kind       = "ClusterFederatedTrustDomain"
    metadata   = { name = "eks" }
    spec = {
      trustDomain           = local.eks_trust_domain
      bundleEndpointURL     = "https://spire-eks.${var.domain}"
      bundleEndpointProfile = { type = "https_web" }
    }
  })
}

# Expose each SPIRE server's federation bundle endpoint so the peer can fetch the
# trust bundle. Routed through the local Traefik websecure entrypoint (LE cert).
resource "kubectl_manifest" "spire_eks_bundle_route" {
  provider   = kubectl.eks
  depends_on = [module.traefik, module.spire_eks]
  yaml_body = yamlencode({
    apiVersion = "traefik.io/v1alpha1"
    kind       = "IngressRoute"
    metadata   = { name = "spire-bundle", namespace = module.spire_eks.namespace }
    spec = {
      entryPoints = ["websecure"]
      routes = [{
        kind     = "Rule"
        match    = "Host(`spire-eks.${var.domain}`)"
        services = [{ name = "spire-server-federation", port = 8443 }]
      }]
    }
  })
}

resource "kubectl_manifest" "spire_aks_bundle_route" {
  provider   = kubectl.aks
  depends_on = [module.aks_traefik, module.spire_aks]
  yaml_body = yamlencode({
    apiVersion = "traefik.io/v1alpha1"
    kind       = "IngressRoute"
    metadata   = { name = "spire-bundle", namespace = module.spire_aks.namespace }
    spec = {
      entryPoints = ["websecure"]
      routes = [{
        kind     = "Rule"
        match    = "Host(`spire-aks.${var.domain}`)"
        services = [{ name = "spire-server-federation", port = 8443 }]
      }]
    }
  })
}
