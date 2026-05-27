resource "helm_release" "keycloak" {
  name      = var.name
  namespace = var.namespace
  chart     = var.chart
  wait      = true
  timeout   = 600

  values = [
    yamlencode({
      namespace = var.namespace

      global = {
        domain = var.domain
      }

      ingress = {
        enabled       = var.ingress.enabled
        domain        = var.ingress.domain != "" ? var.ingress.domain : var.domain
        entrypoint    = var.ingress.entrypoint
        observability = var.ingress_observability
        annotations   = var.ingress_annotations
      }

      keycloak = {
        instances = var.instances
      }

      realm = {
        name                = "traefik"
        accessTokenLifespan = var.access_token_lifespan
        users               = var.users
        advancedUsers       = var.advanced_users
        redirectUris        = var.redirect_uris
      }
    })
  ]
}
