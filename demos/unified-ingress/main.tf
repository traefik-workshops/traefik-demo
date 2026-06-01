# demos/unified-ingress — multi-cloud Traefik Hub mesh. EKS is the hub (the
# unified ingress); EC2, ECS, and AKS join as spokes over SPIFFE-mTLS Hub
# uplinks. This file is the EKS hub baseline. The rest layers in via:
#   nginx-migration.tf  (NGINX -> Traefik provider migration)
#   spire.tf            (SPIRE for SPIFFE-mTLS uplinks)
#   spokes-*.tf         (EC2 / ECS / AKS children + uplink wiring)
#   routes.tf           (parent <spoke>@multicluster routes)
#   waf.tf, mirroring-failover.tf, apim.tf, ai-mcp-gateway.tf, observability.tf
#
# Cloud demo: CI only `terraform validate`s it (relative module sources resolve
# offline); apply + scenarios are run by hand against AWS (+ Azure, later phases).

# --- EKS hub ------------------------------------------------------------------
module "vpc" {
  source = "../../terraform/compute/aws/vpc"

  name = var.cluster_name
}

module "eks" {
  source = "../../terraform/compute/aws/eks"

  cluster_name       = var.cluster_name
  cluster_location   = var.region
  cluster_node_type  = var.cluster_node_type
  cluster_node_count = var.cluster_node_count
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  public_subnet_ids  = module.vpc.public_subnet_ids
  create_vpc         = false
  update_kubeconfig  = true # ambient kubeconfig for the keycloak token-capture + post-apply kubectl
}

resource "kubernetes_namespace_v1" "traefik" {
  provider = kubernetes.eks
  metadata { name = "traefik" }
}

resource "kubernetes_namespace_v1" "apps" {
  provider = kubernetes.eks
  metadata { name = "apps" }
}

# --- Hub Traefik (the unified ingress) ---------------------------------------
# Parent of the multicluster mesh (children are added in spokes-*.tf / routes.tf).
# Runs the kubernetesIngressNGINX provider so it serves existing nginx Ingress
# objects unchanged — the NGINX -> Traefik migration in nginx-migration.tf.
module "traefik" {
  source = "../../terraform/traefik/k8s"
  providers = {
    helm       = helm.eks
    kubernetes = kubernetes.eks
  }

  namespace             = kubernetes_namespace_v1.traefik.metadata[0].name
  traefik_hub_token     = var.traefik_hub_token
  enable_api_gateway    = true
  enable_api_management = true # the API Portal + APIM CRDs live here (apim.tf)
  enable_offline_mode   = true
  kubeconfig            = abspath(local_file.eks_kubeconfig.filename)

  dashboard_entrypoints = ["websecure"]
  dashboard_match_rule  = "Host(`dashboard.${var.domain}`)"

  # Serve existing nginx Ingress objects without rewriting them.
  custom_providers = {
    kubernetesIngressNGINX = {}
  }

  # Register the Coraza (OWASP CRS) WAF plugin so waf.tf's middleware can use it.
  # CAVEAT: confirm moduleName/version against the Traefik plugin catalog before a
  # live apply — this is best-effort.
  custom_plugins = {
    coraza = {
      moduleName = "github.com/jcchavezs/coraza-http-wasm-traefik"
      version    = "v0.2.2"
    }
  }

  # Parent of the multicluster mesh — dials each spoke's Hub uplink. SPIFFE mTLS
  # on the uplink lands in Phase 2c (serversTransport.spiffe replaces the
  # insecureSkipVerify below). Spoke addresses come from the spokes-*.tf data
  # sources (the spoke Traefik LoadBalancer's public :9443).
  multicluster_provider = {
    enabled      = true
    pollInterval = 5
    pollTimeout  = 5
    children = merge({
      aks = {
        address          = local.aks_uplink_address
        serversTransport = { spiffe = { ids = [local.aks_traefik_spiffe_id] } }
      }
      # EC2 / ECS uplinks (var.enable_vm_spokes): SPIFFE-on-VM/ECS is the
      # documented extension, so the hub verifies these with insecureSkipVerify.
      }, var.enable_vm_spokes ? {
      ec2 = {
        address          = local.ec2_uplink_address
        serversTransport = { insecureSkipVerify = true }
      }
      ecs = {
        address          = local.ecs_uplink_address
        serversTransport = { insecureSkipVerify = true }
      }
    } : {})
  }

  # SPIFFE: read the SVID from the SPIRE agent Workload API (CSI-mounted) so the
  # uplink to each spoke is mutually authenticated by SVID (see spire.tf).
  custom_arguments         = [local.spiffe_workload_api_arg]
  additional_volumes       = local.spiffe_volumes
  additional_volume_mounts = local.spiffe_volume_mounts

  # Telemetry -> the hub OTel collector (metrics -> Prometheus, access logs ->
  # Loki, traces -> Tempo + Langfuse; see observability.tf).
  enable_otlp_metrics     = true
  enable_otlp_traces      = true
  enable_otlp_access_logs = true
  otlp_service_name       = "traefik-hub"
  otlp_address            = "http://opentelemetry-opentelemetry-collector.${kubernetes_namespace_v1.observability.metadata[0].name}.svc.cluster.local:4318"

  # Real DNS + per-host Let's Encrypt over the websecure entrypoint. dns-traefiker
  # owns the domain-secret (Cloudflare token); Traefik's cf resolver reuses it.
  dns_traefiker = {
    enabled       = true
    chart         = abspath("${path.module}/../../helm/dns-traefiker")
    unique_domain = false
    domain        = var.domain
  }
}

# --- whoami on the hub (EKS-local) -------------------------------------------
module "whoami" {
  source = "../../terraform/apps/whoami/k8s"
  providers = {
    kubernetes = kubernetes.eks
    kubectl    = kubectl.eks
  }
  depends_on = [module.traefik]

  # whoami lives in the traefik namespace alongside the Hub API CRDs so the
  # hub.traefik.io/api annotation ties its route to the whoami-api managed API
  # (the default JWT APIAuth in apim.tf then gates it).
  namespace           = kubernetes_namespace_v1.traefik.metadata[0].name
  ingress_annotations = { "hub.traefik.io/api" = "whoami-api" }

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
