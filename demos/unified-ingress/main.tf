# demos/unified-ingress — multicluster Traefik Hub on k3d: one "transit" parent
# cluster + one "app-workload" child. The parent discovers the child's routes
# and serves them under a single entrypoint — the dominant real-world shape.
#
# Cross-cluster on k3d: two k3d clusters share one host, so they can't share
# host ports. The child's Traefik (443) is exposed on host port 9443, and the
# parent reaches it at host.k3d.internal:9443.

# --- Clusters -----------------------------------------------------------------
module "transit_cluster" {
  source       = "../../terraform/compute/suse/k3d"
  cluster_name = "${var.cluster_prefix}-transit"
  # default ports: 80/443/8080 on the host
}

module "app_workload_cluster" {
  source       = "../../terraform/compute/suse/k3d"
  cluster_name = "${var.cluster_prefix}-app"
  # Non-colliding host ports; the parent reaches this cluster's Traefik at
  # host.k3d.internal:9443.
  ports = [
    { from = 443, to = 9443 },
    { from = 80, to = 9080 },
  ]
}

# --- Providers (one set per cluster; k3d uses client-cert auth) ---------------
provider "k3d" {}

provider "kubernetes" {
  alias                  = "transit"
  host                   = module.transit_cluster.host
  client_certificate     = module.transit_cluster.client_certificate
  client_key             = module.transit_cluster.client_key
  cluster_ca_certificate = module.transit_cluster.cluster_ca_certificate
}

provider "kubernetes" {
  alias                  = "app_workload"
  host                   = module.app_workload_cluster.host
  client_certificate     = module.app_workload_cluster.client_certificate
  client_key             = module.app_workload_cluster.client_key
  cluster_ca_certificate = module.app_workload_cluster.cluster_ca_certificate
}

provider "helm" {
  alias = "transit"
  kubernetes = {
    host                   = module.transit_cluster.host
    client_certificate     = module.transit_cluster.client_certificate
    client_key             = module.transit_cluster.client_key
    cluster_ca_certificate = module.transit_cluster.cluster_ca_certificate
  }
}

provider "helm" {
  alias = "app_workload"
  kubernetes = {
    host                   = module.app_workload_cluster.host
    client_certificate     = module.app_workload_cluster.client_certificate
    client_key             = module.app_workload_cluster.client_key
    cluster_ca_certificate = module.app_workload_cluster.cluster_ca_certificate
  }
}

# kubectl providers for the whoami IngressRoute (a kubectl_manifest), per cluster.
provider "kubectl" {
  alias                  = "transit"
  host                   = module.transit_cluster.host
  client_certificate     = module.transit_cluster.client_certificate
  client_key             = module.transit_cluster.client_key
  cluster_ca_certificate = module.transit_cluster.cluster_ca_certificate
  load_config_file       = false
}

provider "kubectl" {
  alias                  = "app_workload"
  host                   = module.app_workload_cluster.host
  client_certificate     = module.app_workload_cluster.client_certificate
  client_key             = module.app_workload_cluster.client_key
  cluster_ca_certificate = module.app_workload_cluster.cluster_ca_certificate
  load_config_file       = false
}

# Per-cluster kubeconfigs for each traefik module's CRD local-exec (no current
# context yet — the clusters are created in this same run).
resource "local_file" "transit_kubeconfig" {
  filename        = "${path.module}/.transit.kubeconfig"
  file_permission = "0600"
  content = yamlencode({
    apiVersion        = "v1"
    kind              = "Config"
    "current-context" = "transit"
    clusters          = [{ name = "transit", cluster = { server = module.transit_cluster.host, "certificate-authority-data" = base64encode(module.transit_cluster.cluster_ca_certificate) } }]
    users             = [{ name = "transit", user = { "client-certificate-data" = base64encode(module.transit_cluster.client_certificate), "client-key-data" = base64encode(module.transit_cluster.client_key) } }]
    contexts          = [{ name = "transit", context = { cluster = "transit", user = "transit" } }]
  })
}

resource "local_file" "app_workload_kubeconfig" {
  filename        = "${path.module}/.app.kubeconfig"
  file_permission = "0600"
  content = yamlencode({
    apiVersion        = "v1"
    kind              = "Config"
    "current-context" = "app"
    clusters          = [{ name = "app", cluster = { server = module.app_workload_cluster.host, "certificate-authority-data" = base64encode(module.app_workload_cluster.cluster_ca_certificate) } }]
    users             = [{ name = "app", user = { "client-certificate-data" = base64encode(module.app_workload_cluster.client_certificate), "client-key-data" = base64encode(module.app_workload_cluster.client_key) } }]
    contexts          = [{ name = "app", context = { cluster = "app", user = "app" } }]
  })
}

# --- Transit (parent) ---------------------------------------------------------
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
  enable_offline_mode   = true
  kubeconfig            = abspath(local_file.transit_kubeconfig.filename)

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
        address          = "https://host.k3d.internal:9443"
        serversTransport = { insecureSkipVerify = true }
      }
    }
  }
}

# --- App-workload (child) -----------------------------------------------------
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
  enable_offline_mode   = true
  dashboard_entrypoints = ["websecure"]
  kubeconfig            = abspath(local_file.app_workload_kubeconfig.filename)
}

module "whoami" {
  source = "../../terraform/apps/whoami/k8s"
  providers = {
    helm       = helm.app_workload
    kubernetes = kubernetes.app_workload
    kubectl    = kubectl.app_workload
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
