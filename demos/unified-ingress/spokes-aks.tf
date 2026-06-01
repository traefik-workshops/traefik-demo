# Phase 2 — AKS spoke: a Traefik Hub child joined to the EKS hub over a Hub
# multicluster uplink. Phase 3 adds the AI + MCP gateway here; Phase 2c secures
# the uplink with SPIFFE mTLS (see spire.tf).

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "aks" {
  name     = var.resource_group_name
  location = var.azure_region
}

module "aks" {
  source = "../../terraform/compute/azure/aks"

  cluster_name        = "${var.cluster_name}-aks"
  resource_group_name = azurerm_resource_group.aks.name
  cluster_location    = var.azure_region
  aks_version         = var.aks_version
  cluster_node_type   = var.aks_node_type
  cluster_node_count  = var.aks_node_count

  # Don't touch the ambient kubectl context. The EKS module already set it (EKS
  # current), and the keycloak token-capture data source reads the EKS cluster via
  # the ambient kubeconfig — update_kubeconfig=true here would `az aks
  # get-credentials` and repoint it at AKS, breaking the capture.
  update_kubeconfig = false
}

# AKS providers (cert-based, from the AKS kube_config outputs — raw PEM, unlike
# the EKS module's base64 outputs).
provider "kubernetes" {
  alias                  = "aks"
  host                   = module.aks.host
  client_certificate     = module.aks.client_certificate
  client_key             = module.aks.client_key
  cluster_ca_certificate = module.aks.cluster_ca_certificate
}

provider "helm" {
  alias = "aks"
  kubernetes = {
    host                   = module.aks.host
    client_certificate     = module.aks.client_certificate
    client_key             = module.aks.client_key
    cluster_ca_certificate = module.aks.cluster_ca_certificate
  }
}

provider "kubectl" {
  alias                  = "aks"
  host                   = module.aks.host
  client_certificate     = module.aks.client_certificate
  client_key             = module.aks.client_key
  cluster_ca_certificate = module.aks.cluster_ca_certificate
  load_config_file       = false
}

# Kubeconfig for the AKS child traefik module's CRD install (no current context).
resource "local_file" "aks_kubeconfig" {
  filename        = "${path.module}/.aks.kubeconfig"
  file_permission = "0600"
  content = yamlencode({
    apiVersion        = "v1"
    kind              = "Config"
    "current-context" = "aks"
    clusters          = [{ name = "aks", cluster = { server = module.aks.host, "certificate-authority-data" = base64encode(module.aks.cluster_ca_certificate) } }]
    users             = [{ name = "aks", user = { "client-certificate-data" = base64encode(module.aks.client_certificate), "client-key-data" = base64encode(module.aks.client_key) } }]
    contexts          = [{ name = "aks", context = { cluster = "aks", user = "aks" } }]
  })
}

resource "kubernetes_namespace_v1" "aks_traefik" {
  provider = kubernetes.aks
  metadata { name = "traefik" }
}

resource "kubernetes_namespace_v1" "aks_apps" {
  provider = kubernetes.aks
  metadata { name = "apps" }
}

# --- AKS child Traefik (uplink to the EKS hub) -------------------------------
module "aks_traefik" {
  source = "../../terraform/traefik/k8s"
  providers = {
    helm       = helm.aks
    kubernetes = kubernetes.aks
  }

  namespace             = kubernetes_namespace_v1.aks_traefik.metadata[0].name
  traefik_hub_token     = var.traefik_hub_token
  enable_api_gateway    = true
  enable_ai_gateway     = true
  enable_mcp_gateway    = true
  enable_offline_mode   = true
  kubeconfig            = abspath(local_file.aks_kubeconfig.filename)
  dashboard_entrypoints = ["websecure"]

  # Multicluster child: expose a Hub uplink entrypoint the EKS hub dials. The
  # entrypoint name ("aks") matches the parent's child key + the <aks>@multicluster
  # service ref. expose=default publishes :9443 on the AKS Traefik LoadBalancer.
  multicluster_provider = { enabled = true }
  custom_ports = {
    "aks" = {
      port   = 9443
      uplink = true
      expose = { default = true }
      http   = { tls = { enabled = true } }
    }
  }
  custom_arguments = [
    "--hub.uplinkEntryPoints.aks.address=:9443",
    "--hub.uplinkEntryPoints.aks.http.tls=true",
    local.spiffe_workload_api_arg,
  ]
  additional_volumes       = local.spiffe_volumes
  additional_volume_mounts = local.spiffe_volume_mounts

  # AI-gateway traces (+ metrics / access logs) -> the hub OTel collector (Langfuse).
  enable_otlp_metrics     = true
  enable_otlp_traces      = true
  enable_otlp_access_logs = true
  otlp_service_name       = "traefik-aks"
  otlp_address            = "https://otel.${var.domain}"
}

# whoami on AKS, advertised over the uplink (Host owned by the parent route).
module "aks_whoami" {
  source = "../../terraform/apps/whoami/k8s"
  providers = {
    kubernetes = kubernetes.aks
    kubectl    = kubectl.aks
  }
  depends_on = [module.aks_traefik]

  namespace      = kubernetes_namespace_v1.aks_apps.metadata[0].name
  uplink_enabled = true
  uplink_name    = "aks"
  apps = {
    whoami = {
      ingress_route = { enabled = true }
    }
  }
}

# The AKS Traefik LoadBalancer's public address — the EKS hub dials :9443 here.
data "kubernetes_service_v1" "aks_traefik" {
  provider   = kubernetes.aks
  depends_on = [module.aks_traefik]
  metadata {
    name      = "traefik"
    namespace = kubernetes_namespace_v1.aks_traefik.metadata[0].name
  }
}

locals {
  # Uplink endpoint the EKS hub's multicluster provider dials. SPIFFE (Phase 2c)
  # verifies the child by SVID, so the raw IP is fine. `try` keeps plan/validate
  # happy before the Azure LB IP is assigned; it resolves on apply once the AKS
  # Traefik is up (apply the AKS spoke before the hub parent — see README).
  aks_uplink_address = "https://${try(data.kubernetes_service_v1.aks_traefik.status[0].load_balancer[0].ingress[0].ip, "PENDING")}:9443"
}
