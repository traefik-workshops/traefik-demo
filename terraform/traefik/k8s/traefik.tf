# =============================================================================
# K8s Traefik Deployment
# =============================================================================
# Uses module.config.helm_values as base configuration, merged with K8s-specific
# overrides (redis, knative, gateway, providers, RBAC).
# =============================================================================

locals {
  # Combine shared arguments with K8s-specific ones
  additional_arguments = module.config.cli_arguments

  # K8s-specific volumes for file provider + user-provided additional volumes
  deployment_volumes = concat(
    var.file_provider_config != "" ? [{
      name      = "traefik-dynamic-config"
      configMap = { name = "traefik-dynamic-config" }
    }] : [],
    var.additional_volumes,
  )

  volume_mounts = concat(
    var.file_provider_config != "" ? [{
      name      = "traefik-dynamic-config"
      mountPath = "/etc/traefik/dynamic/"
    }] : [],
    var.additional_volume_mounts,
  )

  # K8s-specific overrides to merge with shared helm_values
  k8s_overrides = {
    # Hub - extend with K8s-specific redis config for API Management
    hub = var.enable_api_gateway || var.enable_api_management ? merge(
      try(module.config.helm_values.hub, {}),
      merge(
        { token = "traefik-hub-license" },
        var.enable_api_management ? {
          apimanagement = { enabled = true }
        } : {}
      ),
      var.enable_api_management ? {
        redis = {
          endpoints = "traefik-redis.${var.namespace}.svc:6379"
          password  = var.redis_password
          database  = "0"
          sentinel  = { enabled = false }
          cluster   = false
        }
      } : {}
    ) : null

    # Deployment configuration
    deployment = {
      kind              = var.deploymentType
      replicas          = module.config.replica_count
      additionalVolumes = local.deployment_volumes
      podAnnotations = var.file_provider_config != "" ? {
        "checksum/fileprovider" = sha256(var.file_provider_config)
      } : {}
    }

    # Service configuration
    service = {
      kind                  = var.serviceType
      annotations           = var.service_annotations
      externalTrafficPolicy = var.external_traffic_policy
    }

    # IngressClass configuration
    ingressClass = {
      enabled        = true
      isDefaultClass = var.ingress_class_is_default
      name           = var.ingress_class_name
    }

    # Environment variables
    env = concat(
      var.dns_traefiker.enabled && length(data.kubernetes_secret_v1.dns_domain) > 0 ? [{ name = "CF_DNS_API_TOKEN", value = data.kubernetes_secret_v1.dns_domain[0].data["token"] }] : [],
      module.config.env_vars_list
    )

    # K8s providers (not in shared)
    providers = merge({
      kubernetesCRD = merge({
        allowCrossNamespace       = true
        allowExternalNameServices = true
        }, length(var.kubernetes_namespaces) > 0 ? {
        namespaces = var.kubernetes_namespaces
      } : {})
      kubernetesIngress = merge({
        allowExternalNameServices = true
        }, length(var.kubernetes_namespaces) > 0 ? {
        namespaces = var.kubernetes_namespaces
      } : {})
      kubernetesGateway = merge({
        enabled             = false
        experimentalChannel = false
        }, length(var.kubernetes_namespaces) > 0 ? {
        namespaces = var.kubernetes_namespaces
      } : {})
      }, var.enable_knative_provider ? {
      knative = {
        enabled = true
      }
    } : {}, var.custom_providers)

    experimental = {
      kubernetesGateway = { enabled = false }
      knative           = var.enable_knative_provider
    }

    # Gateway API listeners (K8s-specific)
    gateway = {
      listeners = {
        web = {
          port            = 80
          protocol        = "HTTP"
          namespacePolicy = { from = "All" }
        }
        traefik = {
          port            = 8080
          protocol        = "HTTP"
          namespacePolicy = { from = "All" }
        }
      }
    }

    # Pod security (K8s-specific)
    podSecurityContext = {
      fsGroup             = 65532
      fsGroupChangePolicy = "OnRootMismatch"
    }

    # Resources and tolerations (K8s-specific)
    resources   = var.resources
    tolerations = var.tolerations

    # Additional arguments and volumes (K8s-specific)
    additionalArguments    = local.additional_arguments
    additionalVolumeMounts = local.volume_mounts
    extraObjects           = var.custom_objects
  }
}

# K8s Secrets
resource "kubernetes_secret_v1" "traefik-hub-license" {
  count = var.enable_api_gateway || var.enable_api_management ? 1 : 0

  metadata {
    name      = "traefik-hub-license"
    namespace = var.namespace
  }

  type = "Opaque"
  data = {
    token = var.traefik_hub_token
  }
}

# File provider ConfigMap
resource "kubernetes_config_map_v1" "traefik-dynamic-config" {
  count = var.file_provider_config != "" ? 1 : 0

  metadata {
    name      = "traefik-dynamic-config"
    namespace = var.namespace
  }

  data = {
    "dynamic.yaml" = var.file_provider_config
  }
}

# Helm release - merge shared helm_values with K8s overrides
resource "helm_release" "traefik" {
  name             = var.name
  repository       = "https://traefik.github.io/charts"
  chart            = "traefik"
  version          = var.traefik_chart_version
  namespace        = var.namespace
  create_namespace = true
  atomic           = true
  wait             = true
  timeout          = 900

  values = [
    # Base values from shared module
    yamlencode(module.config.helm_values),
    # K8s-specific overrides (strip null values)
    yamlencode({ for k, v in local.k8s_overrides : k => v if v != null }),
    # User-provided extra values
    yamlencode(var.extra_values)
  ]

  depends_on = [
    kubernetes_secret_v1.traefik-hub-license,
    kubernetes_config_map_v1.traefik-dynamic-config,
    null_resource.traefik-crds,
    helm_release.dns-traefiker
  ]
}

resource "helm_release" "dns-traefiker" {
  count = var.dns_traefiker.enabled ? 1 : 0

  name      = "dns-traefiker"
  namespace = var.namespace

  chart = var.dns_traefiker.chart

  values = [
    yamlencode({
      uniqueDomain            = var.dns_traefiker.unique_domain
      domain                  = var.dns_traefiker.domain
      enableAirlinesSubdomain = var.dns_traefiker.enable_airlines_subdomain
      ipOverride              = var.dns_traefiker.ip_override
      proxied                 = var.dns_traefiker.proxied
      traefikServiceName      = "traefik"
      traefikServiceNamespace = var.namespace
    })
  ]
}

data "kubernetes_secret_v1" "dns_domain" {
  count = var.dns_traefiker.enabled ? 1 : 0

  metadata {
    name      = "domain-secret"
    namespace = var.namespace
  }

  depends_on = [helm_release.dns-traefiker]
}

# Redis for API Management
module "redis" {
  source = "../../tools/redis/k8s"
  count  = var.enable_api_management ? 1 : 0

  name         = "traefik-redis"
  namespace    = var.namespace
  password     = var.redis_password
  replicaCount = 1
}
