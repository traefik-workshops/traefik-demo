# spire — SPIRE (SPIFFE Runtime Environment) on Kubernetes via the
# spiffe/helm-charts-hardened charts. Installs the CRDs first, then the umbrella
# chart (spire-server + spire-agent + spiffe-csi-driver + spire-controller-manager).
# Issues SVIDs that Traefik consumes for SPIFFE-mTLS multicluster uplinks.

resource "kubernetes_namespace_v1" "this" {
  count = var.create_namespace ? 1 : 0

  metadata {
    name = var.namespace
  }
}

# CRDs go in first — the umbrella chart's controller-manager reconciles
# ClusterSPIFFEID / ClusterFederatedTrustDomain, which must exist beforehand.
resource "helm_release" "crds" {
  name       = "${var.name}-crds"
  namespace  = var.namespace
  repository = var.chart_repository
  chart      = "spire-crds"
  version    = var.spire_crds_chart_version

  depends_on = [kubernetes_namespace_v1.this]
}

locals {
  # Base values every install needs. The caller's var.values is layered on top
  # (helm deep-merges values files left-to-right) for attestors, ClusterSPIFFEID
  # defaults, resource tuning, etc.
  base_values = {
    global = {
      spire = {
        trustDomain = var.trust_domain
        clusterName = var.cluster_name
        caSubject = {
          country      = var.ca_subject.country
          organization = var.ca_subject.organization
          commonName   = var.ca_subject.common_name
        }
      }
    }
    # Expose the federation bundle endpoint so peer trust domains can fetch this
    # cluster's bundle (cross-cluster SPIFFE-mTLS). Off by default.
    "spire-server" = var.enable_federation ? {
      federation = {
        enabled = true
      }
    } : {}
  }
}

resource "helm_release" "this" {
  name       = var.name
  namespace  = var.namespace
  repository = var.chart_repository
  chart      = "spire"
  version    = var.spire_chart_version

  values = [
    yamlencode(local.base_values),
    yamlencode(var.values),
  ]

  depends_on = [helm_release.crds]
}
