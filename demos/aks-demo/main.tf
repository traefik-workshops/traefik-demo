# demos/aks-demo — Traefik Hub API Management on AKS, end to end:
#
#   * Keycloak issues JWTs; a default Hub APIAuth enforces them on the whoami API.
#   * A developer API Portal signs users in with Keycloak SSO (OIDC).
#   * Observability flows over OpenTelemetry: Traefik metrics -> Prometheus and
#     access logs -> Loki (the Grafana stack), and Traefik traces -> Langfuse.
#
# Real DNS + Let's Encrypt make this work without hairpin tricks: the
# dns-traefiker controller registers *.<domain> at the Traefik LoadBalancer IP
# and hands its Cloudflare token to Traefik's `cf` cert resolver, so
# keycloak.<domain> (issuer + JWKS) and portal.<domain> (OIDC redirect) are
# reachable by both the browser and Hub. Cloud demo — validate-only in CI.
#
# Layout mirrors demos/oidc-portal (cloud + API Portal) with EKS+Cognito swapped
# for AKS+Keycloak, plus the observability stack and dns-traefiker. The Hub APIM
# CRDs are the helm/airlines shapes, trimmed to the single whoami API.

# --- Cluster ------------------------------------------------------------------
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "demo" {
  name     = var.resource_group_name
  location = var.region
}

module "cluster" {
  source = "../../terraform/compute/azure/aks"

  cluster_name        = var.cluster_name
  resource_group_name = azurerm_resource_group.demo.name
  cluster_location    = var.region
  aks_version         = var.aks_version
  cluster_node_type   = var.cluster_node_type
  cluster_node_count  = var.cluster_node_count

  # The apply is self-contained — providers authenticate with the kube_config
  # client cert, and the CRD install / token capture use the kubeconfig file
  # built below. We still let the module run `az aks get-credentials` to merge
  # the cluster into your ambient kubeconfig and set it current, so kubectl / k9s
  # work against it right after `make up`.
  update_kubeconfig = true
}

# --- Providers (cert-based, from the AKS kube_config outputs) ------------------
provider "kubernetes" {
  host                   = module.cluster.host
  client_certificate     = module.cluster.client_certificate
  client_key             = module.cluster.client_key
  cluster_ca_certificate = module.cluster.cluster_ca_certificate
}

provider "helm" {
  kubernetes = {
    host                   = module.cluster.host
    client_certificate     = module.cluster.client_certificate
    client_key             = module.cluster.client_key
    cluster_ca_certificate = module.cluster.cluster_ca_certificate
  }
}

# Used by the whoami module + the Hub APIM CRDs below (kubectl_manifest applies
# raw YAML at apply time, so it doesn't need the traefik.io/hub.traefik.io CRDs
# to exist at plan time — unlike kubernetes_manifest).
provider "kubectl" {
  host                   = module.cluster.host
  client_certificate     = module.cluster.client_certificate
  client_key             = module.cluster.client_key
  cluster_ca_certificate = module.cluster.cluster_ca_certificate
  load_config_file       = false
}

# The traefik module installs CRDs via a local-exec kubectl, which needs a
# kubeconfig — the cluster is created in this same run, so there's no current
# context. Build one from the cluster's cert outputs (same trick as the k3d
# demos), and feed the keycloak token-capture data source the raw certs.
locals {
  kubeconfig = yamlencode({
    apiVersion        = "v1"
    kind              = "Config"
    "current-context" = var.cluster_name
    clusters          = [{ name = var.cluster_name, cluster = { server = module.cluster.host, "certificate-authority-data" = base64encode(module.cluster.cluster_ca_certificate) } }]
    users             = [{ name = var.cluster_name, user = { "client-certificate-data" = base64encode(module.cluster.client_certificate), "client-key-data" = base64encode(module.cluster.client_key) } }]
    contexts          = [{ name = var.cluster_name, context = { cluster = var.cluster_name, user = var.cluster_name } }]
  })
}

resource "local_file" "kubeconfig" {
  content         = local.kubeconfig
  filename        = "${path.module}/.kubeconfig"
  file_permission = "0600"
}

# --- Namespaces ---------------------------------------------------------------
# Traefik + every Hub APIM CRD + the whoami API all share one namespace (the
# helm/airlines model) so the API <-> route <-> portal links resolve cleanly.
resource "kubernetes_namespace_v1" "traefik" {
  metadata { name = "traefik" }
}
resource "kubernetes_namespace_v1" "security" {
  metadata { name = "security" }
}
resource "kubernetes_namespace_v1" "observability" {
  metadata { name = "traefik-observability" }
}
resource "kubernetes_namespace_v1" "monitoring" {
  metadata { name = "monitoring" }
}

# --- Traefik Hub --------------------------------------------------------------
# dns-traefiker (deployed by the traefik module) owns the `domain-secret`: it
# holds the Cloudflare token, watches the Traefik LoadBalancer, and registers
# *.<domain>. The traefik module reads that same secret for CF_DNS_API_TOKEN
# (Let's Encrypt DNS-01) — so this demo takes no Cloudflare input.
module "traefik" {
  source = "../../terraform/traefik/k8s"

  namespace             = kubernetes_namespace_v1.traefik.metadata[0].name
  traefik_hub_token     = var.traefik_hub_token
  enable_api_gateway    = true
  enable_api_management = true # the API Portal + APIM CRDs live here
  enable_offline_mode   = true
  kubeconfig            = abspath(local_file.kubeconfig.filename)

  dashboard_entrypoints = ["websecure"]
  dashboard_match_rule  = "Host(`dashboard.${var.domain}`)"

  # Telemetry -> OTel collector. Metrics + access logs feed the Grafana stack,
  # traces feed Langfuse (the collector fans them out — see the observability
  # modules below).
  enable_otlp_metrics     = true
  enable_otlp_traces      = true
  enable_otlp_access_logs = true
  otlp_service_name       = "traefik"
  otlp_address            = "http://opentelemetry-opentelemetry-collector.${kubernetes_namespace_v1.observability.metadata[0].name}.svc.cluster.local:4318"

  # Real DNS + per-host Let's Encrypt certs over the websecure entrypoint.
  dns_traefiker = {
    enabled       = true
    chart         = abspath("${path.module}/../../helm/dns-traefiker")
    unique_domain = false
    domain        = var.domain
  }
}

# --- Keycloak (IdP) -----------------------------------------------------------
# Seeds a `developer` user in group `developers`, exposes the UI at
# keycloak.<domain>, and mints a per-user JWT into the `traefik-user-tokens`
# secret (scenarios.sh reads it to exercise the whoami API).
module "keycloak" {
  source = "../../terraform/security/keycloak/k8s"

  namespace = kubernetes_namespace_v1.security.metadata[0].name
  chart     = abspath("${path.module}/../../helm/keycloak")
  domain    = var.domain

  # A single `developer` user. The simple `users` list puts them in group
  # `developers` (username + "s") with password var.user_password (default
  # "topsecretpassword"), which the module threads into BOTH the realm and the
  # token-mint Job — so the JWT in the traefik-user-tokens secret actually mints.
  users         = ["developer"]
  redirect_uris = ["portal"] # -> https://portal.<domain>/callback

  ingress = {
    enabled    = true
    entrypoint = "websecure"
    domain     = var.domain
  }

  # The token-capture data source builds its own kubectl context from these
  # (no reliable ambient kubeconfig — the cluster is created in this run).
  host               = module.cluster.host
  client_certificate = module.cluster.client_certificate
  client_key         = module.cluster.client_key

  # Needs the traefik.io Middleware CRD (used by the Keycloak ingress).
  depends_on = [module.traefik]
}

# --- Observability: OTel collector + Langfuse (traces) ------------------------
module "langfuse" {
  source = "../../terraform/observability/langfuse/k8s"

  namespace = kubernetes_namespace_v1.observability.metadata[0].name

  # ingress is created below as a kubectl_manifest IngressRoute (the module's
  # built-in ingress uses kubernetes_manifest, which can't plan against a CRD
  # that doesn't exist yet on a fresh cluster).
  ingress = false
}

module "opentelemetry" {
  source = "../../terraform/observability/opentelemetry/k8s"

  namespace = kubernetes_namespace_v1.observability.metadata[0].name

  # Metrics -> exposed on :8889 for the Grafana stack's Prometheus to scrape.
  enable_prometheus = true

  # Access logs -> Loki (in the Grafana stack).
  enable_loki   = true
  loki_endpoint = "http://loki.${kubernetes_namespace_v1.monitoring.metadata[0].name}.svc.cluster.local:3100/otlp"

  # Traces -> Grafana Tempo (so they show in Grafana, via the wired Tempo
  # datasource) AND the in-cluster Langfuse. Tempo accepts OTLP on :4318.
  enable_tempo   = true
  tempo_endpoint = "http://tempo.${kubernetes_namespace_v1.monitoring.metadata[0].name}.svc.cluster.local:4318"

  enable_langfuse     = true
  langfuse_endpoint   = module.langfuse.otel_endpoint
  langfuse_public_key = module.langfuse.public_key
  langfuse_secret_key = module.langfuse.secret_key
}

# --- Observability: Grafana stack (metrics + logs) ----------------------------
module "grafana_stack" {
  source = "../../terraform/observability/grafana-stack/k8s"

  namespace = kubernetes_namespace_v1.monitoring.metadata[0].name

  # Scrape Traefik's OTLP metrics off the collector's Prometheus exporter.
  metrics_host = "opentelemetry-opentelemetry-collector.${kubernetes_namespace_v1.observability.metadata[0].name}.svc.cluster.local"
  metrics_port = 8889

  ingress            = true
  ingress_domain     = var.domain
  ingress_entrypoint = "websecure"

  dashboards = {
    aigateway  = false
    mcpgateway = false
    apim       = true
  }

  # Needs the traefik IngressClass / websecure entrypoint for the grafana ingress.
  depends_on = [module.traefik]
}

# Langfuse UI route (see note on the module block above).
resource "kubectl_manifest" "langfuse_route" {
  depends_on = [module.traefik, module.langfuse]

  yaml_body = yamlencode({
    apiVersion = "traefik.io/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      name      = "langfuse-web"
      namespace = kubernetes_namespace_v1.observability.metadata[0].name
    }
    spec = {
      entryPoints = ["websecure"]
      routes = [{
        kind  = "Rule"
        match = "Host(`langfuse.${var.domain}`)"
        services = [{
          name = module.langfuse.web_service_name
          port = 3000
        }]
      }]
    }
  })
}

# --- whoami (the managed API) -------------------------------------------------
# Deployed in the traefik namespace alongside the API CRDs. The IngressRoute
# carries the hub.traefik.io/api annotation that ties it to the whoami-api API,
# so the default JWT APIAuth below applies to it.
module "whoami" {
  source = "../../terraform/apps/whoami/k8s"

  namespace  = kubernetes_namespace_v1.traefik.metadata[0].name
  depends_on = [module.traefik]

  ingress_annotations = {
    "hub.traefik.io/api" = "whoami-api"
  }

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

# --- Hub API Management CRDs --------------------------------------------------
# Trimmed helm/airlines shapes: default JWT auth, the OIDC-protected portal, and
# the whoami API published into the catalog for the `developers` group.
locals {
  traefik_ns  = kubernetes_namespace_v1.traefik.metadata[0].name
  oidc_issuer = "https://keycloak.${var.domain}/realms/traefik"
  oidc_jwks   = "https://keycloak.${var.domain}/realms/traefik/protocol/openid-connect/certs"
}

# Default authentication for every Hub API: a Keycloak-issued JWT. appIdClaim
# reads the multivalued `group` claim Keycloak puts in the access token.
resource "kubectl_manifest" "api_auth_jwt" {
  depends_on = [module.traefik]
  yaml_body = yamlencode({
    apiVersion = "hub.traefik.io/v1alpha1"
    kind       = "APIAuth"
    metadata   = { name = "jwt-auth", namespace = local.traefik_ns }
    spec = {
      isDefault = true
      jwt = {
        appIdClaim = "group"
        jwksUrl    = local.oidc_jwks
      }
    }
  })
}

# Portal SSO credentials (the Keycloak `traefik` client).
resource "kubectl_manifest" "oidc_credentials" {
  depends_on = [module.traefik]
  yaml_body = yamlencode({
    apiVersion = "v1"
    kind       = "Secret"
    metadata   = { name = "oidc-credentials", namespace = local.traefik_ns }
    type       = "Opaque"
    stringData = {
      clientId     = "traefik"
      clientSecret = var.keycloak_client_secret
    }
  })
}

resource "kubectl_manifest" "api_portal_auth" {
  depends_on = [kubectl_manifest.oidc_credentials]
  yaml_body = yamlencode({
    apiVersion = "hub.traefik.io/v1alpha1"
    kind       = "APIPortalAuth"
    metadata   = { name = "oidc-portal-auth", namespace = local.traefik_ns }
    spec = {
      oidc = {
        issuerUrl  = local.oidc_issuer
        secretName = "oidc-credentials"
        scopes     = ["openid", "profile", "email", "group"]
        claims = {
          groups    = "group"
          userId    = "sub"
          email     = "email"
          firstname = "given_name"
          lastname  = "family_name"
        }
        syncedAttributes = ["groups", "email", "firstname", "lastname", "userId"]
      }
    }
  })
}

resource "kubectl_manifest" "api_portal" {
  depends_on = [kubectl_manifest.api_portal_auth]
  yaml_body = yamlencode({
    apiVersion = "hub.traefik.io/v1alpha1"
    kind       = "APIPortal"
    metadata   = { name = "developer-portal", namespace = local.traefik_ns }
    spec = {
      title       = "Developer Portal"
      description = "Self-service catalog for the whoami API. Sign in with Keycloak."
      trustedUrls = ["https://portal.${var.domain}"]
      auth        = { name = "oidc-portal-auth" }
    }
  })
}

# The portal is served by Hub's `apiportal` service; this route exposes it.
resource "kubectl_manifest" "api_portal_route" {
  depends_on = [kubectl_manifest.api_portal]
  yaml_body = yamlencode({
    apiVersion = "traefik.io/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      name        = "developer-portal"
      namespace   = local.traefik_ns
      annotations = { "hub.traefik.io/api-portal" = "developer-portal" }
    }
    spec = {
      entryPoints = ["websecure"]
      routes = [{
        kind  = "Rule"
        match = "Host(`portal.${var.domain}`)"
        services = [{
          name      = "apiportal"
          namespace = local.traefik_ns
          port      = 9903
        }]
      }]
    }
  })
}

# The whoami API + a bundle/plan so it shows in the portal catalog.
resource "kubectl_manifest" "whoami_api" {
  depends_on = [module.traefik]
  yaml_body = yamlencode({
    apiVersion = "hub.traefik.io/v1alpha1"
    kind       = "API"
    metadata = {
      name      = "whoami-api"
      namespace = local.traefik_ns
      labels    = { bundle = "whoami" }
    }
    spec = {
      title       = "Whoami API"
      description = "Echoes the incoming request — protected by a Keycloak JWT."
    }
  })
}

resource "kubectl_manifest" "whoami_bundle" {
  depends_on = [kubectl_manifest.whoami_api]
  yaml_body = yamlencode({
    apiVersion = "hub.traefik.io/v1alpha1"
    kind       = "APIBundle"
    metadata   = { name = "whoami-bundle", namespace = local.traefik_ns }
    spec = {
      title       = "Whoami"
      apiSelector = { matchLabels = { bundle = "whoami" } }
    }
  })
}

resource "kubectl_manifest" "whoami_plan" {
  depends_on = [module.traefik]
  yaml_body = yamlencode({
    apiVersion = "hub.traefik.io/v1alpha1"
    kind       = "APIPlan"
    metadata   = { name = "whoami-plan", namespace = local.traefik_ns }
    spec = {
      title       = "Whoami Access"
      description = "Standard access to the whoami API."
      rateLimit   = { limit = 100, period = "1s" }
      quota       = { limit = 1000, period = "750h" }
    }
  })
}

# Publish the bundle to the portal catalog for the `developers` group (the
# group the seeded `developer` user lands in, carried in the JWT `group` claim).
resource "kubectl_manifest" "whoami_catalog_item" {
  depends_on = [kubectl_manifest.whoami_bundle, kubectl_manifest.whoami_plan, kubectl_manifest.api_portal]
  yaml_body = yamlencode({
    apiVersion = "hub.traefik.io/v1alpha1"
    kind       = "APICatalogItem"
    metadata   = { name = "whoami-access", namespace = local.traefik_ns }
    spec = {
      groups     = ["developers"]
      apiBundles = [{ name = "whoami-bundle" }]
      apiPlan    = { name = "whoami-plan" }
    }
  })
}

# Runtime access. The catalog item only makes whoami *discoverable* in the
# portal. The default JWT APIAuth identifies the caller's app from the `group`
# claim (appIdClaim), so a valid token authenticates (no token = 401) but is
# still forbidden (403) until an application + subscription grant it the bundle.
# Pre-create the subscription for the `developers` group so the developer JWT
# works out of the box (mirrors helm/airlines' ManagedApplication +
# ManagedSubscription). Real users would self-subscribe through the portal.
resource "kubectl_manifest" "developers_application" {
  depends_on = [module.traefik]
  yaml_body = yamlencode({
    apiVersion = "hub.traefik.io/v1alpha1"
    kind       = "ManagedApplication"
    metadata   = { name = "developers-application", namespace = local.traefik_ns }
    spec = {
      appId = "developers"
      owner = "developers"
    }
  })
}

resource "kubectl_manifest" "developers_subscription" {
  depends_on = [kubectl_manifest.developers_application, kubectl_manifest.whoami_bundle, kubectl_manifest.whoami_plan]
  yaml_body = yamlencode({
    apiVersion = "hub.traefik.io/v1alpha1"
    kind       = "ManagedSubscription"
    metadata   = { name = "developers-subscription", namespace = local.traefik_ns }
    spec = {
      managedApplications = [{ name = "developers-application" }]
      apiBundles          = [{ name = "whoami-bundle" }]
      apiPlan             = { name = "whoami-plan" }
    }
  })
}
