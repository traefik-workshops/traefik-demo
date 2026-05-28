# demos/unified-ingress — multicluster Traefik Hub: one transit cluster +
# one or more app-workload clusters.
#
# The most common real-world shape (sampled from aws/lke/k3d/nutanix unified
# ingress demos). Demonstrates: cross-cluster routing, OTel observability,
# auto-DNS via dns-traefiker.

# ----------------------------------------------------------------------------
# Clusters — one "transit" parent + one or more app-workload children.
# Swap the source for any compute/<cloud> module per cluster.
# ----------------------------------------------------------------------------

module "transit_cluster" {
  source = "../../terraform/compute/digitalocean/doks"

  cluster_name     = "${var.cluster_prefix}-transit"
  cluster_location = var.cluster_location
}

module "app_workload_cluster" {
  source = "../../terraform/compute/digitalocean/doks"

  cluster_name     = "${var.cluster_prefix}-app"
  cluster_location = var.cluster_location
}

# ----------------------------------------------------------------------------
# Provider aliases — one set per cluster.
# ----------------------------------------------------------------------------

provider "kubernetes" {
  alias                  = "transit"
  host                   = module.transit_cluster.host
  cluster_ca_certificate = base64decode(module.transit_cluster.cluster_ca_certificate)
  token                  = module.transit_cluster.token
}

provider "kubernetes" {
  alias                  = "app_workload"
  host                   = module.app_workload_cluster.host
  cluster_ca_certificate = base64decode(module.app_workload_cluster.cluster_ca_certificate)
  token                  = module.app_workload_cluster.token
}

provider "helm" {
  alias = "transit"
  kubernetes = {
    host                   = module.transit_cluster.host
    cluster_ca_certificate = base64decode(module.transit_cluster.cluster_ca_certificate)
    token                  = module.transit_cluster.token
  }
}

provider "helm" {
  alias = "app_workload"
  kubernetes = {
    host                   = module.app_workload_cluster.host
    cluster_ca_certificate = base64decode(module.app_workload_cluster.cluster_ca_certificate)
    token                  = module.app_workload_cluster.token
  }
}

# ----------------------------------------------------------------------------
# Transit cluster — Traefik Hub in multicluster-parent mode.
# ----------------------------------------------------------------------------

resource "kubernetes_namespace_v1" "transit_traefik" {
  provider = kubernetes.transit
  metadata { name = "traefik" }
}

resource "kubernetes_namespace_v1" "transit_observability" {
  provider = kubernetes.transit
  metadata { name = "traefik-observability" }
}

module "transit_observability" {
  source = "../../terraform/observability/opentelemetry/k8s"
  providers = {
    helm       = helm.transit
    kubernetes = kubernetes.transit
  }
  namespace = kubernetes_namespace_v1.transit_observability.metadata[0].name
}

module "transit_traefik" {
  source = "../../terraform/traefik/k8s"
  providers = {
    helm       = helm.transit
    kubernetes = kubernetes.transit
  }

  namespace             = kubernetes_namespace_v1.transit_traefik.metadata[0].name
  traefik_hub_token     = var.traefik_hub_token
  enable_api_gateway    = true
  enable_api_management = true

  enable_otlp_metrics     = true
  enable_otlp_traces      = true
  enable_otlp_access_logs = true
  otlp_service_name       = "traefik-transit"
  otlp_address            = "http://opentelemetry-opentelemetry-collector.${kubernetes_namespace_v1.transit_observability.metadata[0].name}.svc.cluster.local:4318"

  dashboard_entrypoints = ["websecure"]
  dashboard_match_rule  = "Host(`dashboard.${var.domain}`)"

  multicluster_provider = {
    enabled      = true
    pollInterval = 5
    pollTimeout  = 5
    children = {
      app-workload = {
        # In a real deploy this points at the app-workload Traefik LB IP.
        address          = "https://${module.app_workload_traefik.load_balancer_ip}:9443"
        serversTransport = { insecureSkipVerify = true }
      }
    }
  }
}

# ----------------------------------------------------------------------------
# App-workload cluster — Traefik Hub as multicluster child + sample app.
# ----------------------------------------------------------------------------

resource "kubernetes_namespace_v1" "app_workload_traefik" {
  provider = kubernetes.app_workload
  metadata { name = "traefik" }
}

resource "kubernetes_namespace_v1" "app_workload_apps" {
  provider = kubernetes.app_workload
  metadata { name = "apps" }
}

module "app_workload_traefik" {
  source = "../../terraform/traefik/k8s"
  providers = {
    helm       = helm.app_workload
    kubernetes = kubernetes.app_workload
  }

  namespace             = kubernetes_namespace_v1.app_workload_traefik.metadata[0].name
  traefik_hub_token     = var.traefik_hub_token
  enable_api_gateway    = true
  dashboard_entrypoints = ["websecure"]
}

module "whoami" {
  source = "../../terraform/apps/whoami/k8s"
  providers = {
    helm       = helm.app_workload
    kubernetes = kubernetes.app_workload
  }
  namespace = kubernetes_namespace_v1.app_workload_apps.metadata[0].name
  apps = {
    whoami = {
      ingress_route = {
        enabled     = true
        host        = "whoami.${var.domain}"
        entrypoints = ["websecure"]
      }
    }
  }
}
