# Phase 5 — Hub API Management + developer Portal on the EKS hub, gated by
# Keycloak (JWT auth + portal OIDC). Trimmed helm/airlines shapes (the aks-demo
# pattern): a default JWT APIAuth on the whoami API, an OIDC-protected portal, and
# the whoami API published to the catalog for the `developers` group.

resource "kubernetes_namespace_v1" "security" {
  provider = kubernetes.eks
  metadata { name = "security" }
}

# Keycloak (IdP) — seeds a `developer` user in group `developers`, exposes the UI
# at keycloak.<domain>, mints a per-user JWT into the traefik-user-tokens secret
# (scenarios.sh reads it to exercise the whoami API gate).
module "keycloak" {
  source = "../../terraform/security/keycloak/k8s"
  providers = {
    helm       = helm.eks
    kubernetes = kubernetes.eks
  }

  namespace = kubernetes_namespace_v1.security.metadata[0].name
  chart     = abspath("${path.module}/../../helm/keycloak")
  domain    = var.domain

  users         = ["developer"]
  redirect_uris = ["portal"] # -> https://portal.<domain>/callback

  ingress = {
    enabled    = true
    entrypoint = "websecure"
    domain     = var.domain
  }

  # host left empty -> the token-capture data source uses the ambient kubeconfig.
  # The EKS module runs `aws eks update-kubeconfig` (update_kubeconfig = true), so
  # the cluster is the current context during apply.
  depends_on = [module.traefik]
}

locals {
  hub_traefik_ns = kubernetes_namespace_v1.traefik.metadata[0].name
  oidc_issuer    = "https://keycloak.${var.domain}/realms/traefik"
  oidc_jwks      = "https://keycloak.${var.domain}/realms/traefik/protocol/openid-connect/certs"
}

# Default authentication for every Hub API: a Keycloak-issued JWT (appIdClaim
# reads the multivalued `group` claim).
resource "kubectl_manifest" "api_auth_jwt" {
  provider   = kubectl.eks
  depends_on = [module.traefik]
  yaml_body = yamlencode({
    apiVersion = "hub.traefik.io/v1alpha1"
    kind       = "APIAuth"
    metadata   = { name = "jwt-auth", namespace = local.hub_traefik_ns }
    spec = {
      isDefault = true
      jwt       = { appIdClaim = "group", jwksUrl = local.oidc_jwks }
    }
  })
}

# Portal SSO credentials (the Keycloak `traefik` client).
resource "kubectl_manifest" "oidc_credentials" {
  provider   = kubectl.eks
  depends_on = [module.traefik]
  yaml_body = yamlencode({
    apiVersion = "v1"
    kind       = "Secret"
    metadata   = { name = "oidc-credentials", namespace = local.hub_traefik_ns }
    type       = "Opaque"
    stringData = { clientId = "traefik", clientSecret = var.keycloak_client_secret }
  })
}

resource "kubectl_manifest" "api_portal_auth" {
  provider   = kubectl.eks
  depends_on = [kubectl_manifest.oidc_credentials]
  yaml_body = yamlencode({
    apiVersion = "hub.traefik.io/v1alpha1"
    kind       = "APIPortalAuth"
    metadata   = { name = "oidc-portal-auth", namespace = local.hub_traefik_ns }
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
  provider   = kubectl.eks
  depends_on = [kubectl_manifest.api_portal_auth]
  yaml_body = yamlencode({
    apiVersion = "hub.traefik.io/v1alpha1"
    kind       = "APIPortal"
    metadata   = { name = "developer-portal", namespace = local.hub_traefik_ns }
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
  provider   = kubectl.eks
  depends_on = [kubectl_manifest.api_portal]
  yaml_body = yamlencode({
    apiVersion = "traefik.io/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      name        = "developer-portal"
      namespace   = local.hub_traefik_ns
      annotations = { "hub.traefik.io/api-portal" = "developer-portal" }
    }
    spec = {
      entryPoints = ["websecure"]
      routes = [{
        kind     = "Rule"
        match    = "Host(`portal.${var.domain}`)"
        services = [{ name = "apiportal", namespace = local.hub_traefik_ns, port = 9903 }]
      }]
    }
  })
}

# The whoami API + a bundle/plan so it shows in the portal catalog.
resource "kubectl_manifest" "whoami_api" {
  provider   = kubectl.eks
  depends_on = [module.traefik]
  yaml_body = yamlencode({
    apiVersion = "hub.traefik.io/v1alpha1"
    kind       = "API"
    metadata = {
      name      = "whoami-api"
      namespace = local.hub_traefik_ns
      labels    = { bundle = "whoami" }
    }
    spec = {
      title       = "Whoami API"
      description = "Echoes the incoming request — protected by a Keycloak JWT."
    }
  })
}

resource "kubectl_manifest" "whoami_bundle" {
  provider   = kubectl.eks
  depends_on = [kubectl_manifest.whoami_api]
  yaml_body = yamlencode({
    apiVersion = "hub.traefik.io/v1alpha1"
    kind       = "APIBundle"
    metadata   = { name = "whoami-bundle", namespace = local.hub_traefik_ns }
    spec       = { title = "Whoami", apiSelector = { matchLabels = { bundle = "whoami" } } }
  })
}

resource "kubectl_manifest" "whoami_plan" {
  provider   = kubectl.eks
  depends_on = [module.traefik]
  yaml_body = yamlencode({
    apiVersion = "hub.traefik.io/v1alpha1"
    kind       = "APIPlan"
    metadata   = { name = "whoami-plan", namespace = local.hub_traefik_ns }
    spec = {
      title       = "Whoami Access"
      description = "Standard access to the whoami API."
      rateLimit   = { limit = 100, period = "1s" }
      quota       = { limit = 1000, period = "750h" }
    }
  })
}

# Publish the bundle to the portal catalog for the `developers` group.
resource "kubectl_manifest" "whoami_catalog_item" {
  provider   = kubectl.eks
  depends_on = [kubectl_manifest.whoami_bundle, kubectl_manifest.whoami_plan, kubectl_manifest.api_portal]
  yaml_body = yamlencode({
    apiVersion = "hub.traefik.io/v1alpha1"
    kind       = "APICatalogItem"
    metadata   = { name = "whoami-access", namespace = local.hub_traefik_ns }
    spec = {
      groups     = ["developers"]
      apiBundles = [{ name = "whoami-bundle" }]
      apiPlan    = { name = "whoami-plan" }
    }
  })
}

# Pre-create the application + subscription for the `developers` group so the
# developer JWT works out of the box (mirrors helm/airlines).
resource "kubectl_manifest" "developers_application" {
  provider   = kubectl.eks
  depends_on = [module.traefik]
  yaml_body = yamlencode({
    apiVersion = "hub.traefik.io/v1alpha1"
    kind       = "ManagedApplication"
    metadata   = { name = "developers-application", namespace = local.hub_traefik_ns }
    spec       = { appId = "developers", owner = "developers" }
  })
}

resource "kubectl_manifest" "developers_subscription" {
  provider   = kubectl.eks
  depends_on = [kubectl_manifest.developers_application, kubectl_manifest.whoami_bundle, kubectl_manifest.whoami_plan]
  yaml_body = yamlencode({
    apiVersion = "hub.traefik.io/v1alpha1"
    kind       = "ManagedSubscription"
    metadata   = { name = "developers-subscription", namespace = local.hub_traefik_ns }
    spec = {
      managedApplications = [{ name = "developers-application" }]
      apiBundles          = [{ name = "whoami-bundle" }]
      apiPlan             = { name = "whoami-plan" }
    }
  })
}
