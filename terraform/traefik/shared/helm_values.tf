# =============================================================================
# Helm values - source of truth for all deployments.
# =============================================================================
# - K8s consumers feed local.helm_values_clean to helm_release.
# - VM consumers (EC2/ECS/Nutanix) render this through `helm template` (see
#   the extract_config data source in main.tf) and pull cli args, env vars,
#   and the static config out of the resulting Pod spec.
#
# additionalArguments and env are factored out into cli_args.tf and env.tf
# to keep this file focused on the Helm values shape.
# =============================================================================

locals {
  helm_values = {
    image = merge(
      {
        repository = local.image_repository
        tag        = local.image_tag
      },
      local.image_registry != "" ? { registry = local.image_registry } : {},
      var.enable_preview_mode ? { pullPolicy = "Always" } : {}
    )

    hub = var.enable_api_gateway || var.enable_api_management || var.enable_preview_mode ? merge({
      token      = var.traefik_hub_token
      offline    = var.enable_offline_mode
      aigateway  = var.enable_ai_gateway ? { enabled = true, maxRequestBodySize = 2097152 } : null
      mcpgateway = var.enable_mcp_gateway ? { enabled = true, maxRequestBodySize = 2097152 } : null
      },
      var.multicluster_provider.enabled ? {
        providers = {
          multicluster = merge(
            { enabled = true },
            var.multicluster_provider.pollInterval != null ? { pollInterval = var.multicluster_provider.pollInterval } : {},
            var.multicluster_provider.pollTimeout != null ? { pollTimeout = var.multicluster_provider.pollTimeout } : {},
            length(var.multicluster_provider.children) > 0 ? { children = var.multicluster_provider.children } : {}
          )
        }
      } : {}
    ) : null

    ports = merge(
      {
        web = {
          port     = var.entry_points.web.port
          expose   = { default = true }
          protocol = "TCP"
        }
        websecure = {
          port     = var.entry_points.websecure.port
          expose   = { default = true }
          protocol = "TCP"
        }
        traefik = {
          port   = var.entry_points.traefik.port
          expose = { default = true }
        }
      },
      var.enable_prometheus ? {
        prometheus = {
          port        = 9101
          expose      = { default = true }
          exposedPort = 9101
          protocol    = "TCP"
        }
      } : {},
      var.custom_ports
    )

    api = {
      dashboard = var.enable_dashboard
      insecure  = var.dashboard_insecure
      debug     = var.enable_debug
    }

    additionalArguments = local.additional_arguments

    env = local.env_vars

    logs = {
      general = {
        level = var.log_level
        otlp = {
          enabled     = var.enable_otlp_application_logs
          serviceName = var.otlp_service_name
          http = merge({
            enabled  = true
            endpoint = "${local.otlp_endpoint}/v1/logs"
            },
            startswith(local.otlp_endpoint, "https://") ? {
              tls = { insecureSkipVerify = true }
            } : {}
          )
        }
      }
      access = {
        enabled = var.enable_access_logs
        filters = {
          statuscodes = "200-599"
        }
        otlp = {
          enabled     = var.enable_otlp_access_logs
          serviceName = var.otlp_service_name
          http = merge({
            enabled  = true
            endpoint = "${local.otlp_endpoint}/v1/logs"
            },
            startswith(local.otlp_endpoint, "https://") ? {
              tls = { insecureSkipVerify = true }
            } : {}
          )
        }
      }
    }

    # The Traefik Helm chart uses `{{- with .Values.metrics.prometheus }}`
    # which is truthy for any non-null map (even with enabled:false). To
    # actually disable the endpoint we must set the key to null so Helm
    # merges it away from the chart defaults.
    metrics = {
      prometheus = var.enable_prometheus ? {
        enabled              = true
        addEntryPointsLabels = true
        addRoutersLabels     = true
        addServicesLabels    = true
      } : null
      otlp = var.enable_otlp_metrics ? {
        enabled              = true
        addEntryPointsLabels = true
        addRoutersLabels     = true
        addServicesLabels    = true
        http = merge({
          enabled  = true
          endpoint = "${local.otlp_endpoint}/v1/metrics"
          },
          # Traefik rejects TLS config on http:// endpoints: "insecure HTTP
          # endpoint cannot use TLS client configuration". Only include tls
          # when the endpoint is actually TLS.
          startswith(local.otlp_endpoint, "https://") ? {
            tls = { insecureSkipVerify = true }
          } : {}
        )
      } : null
    }

    tracing = var.enable_otlp_traces && var.otlp_address != "" ? {
      serviceName = var.otlp_service_name
      otlp = {
        enabled = true
        http = merge({
          enabled  = true
          endpoint = "${local.otlp_endpoint}/v1/traces"
          },
          startswith(local.otlp_endpoint, "https://") ? {
            tls = { insecureSkipVerify = true }
          } : {}
        )
      }
    } : null

    experimental = merge({
      otlpLogs = true
      }, length(var.custom_plugins) > 0 ? {
      plugins = var.custom_plugins
    } : null)

    certificatesResolvers = var.cloudflare_dns.enabled || var.dns_traefiker.enabled ? jsondecode(
      var.use_distributed_acme && var.traefik_hub_token != "" ? jsonencode({
        cf = {
          distributedAcme = {
            email    = "zaid@traefik.io"
            caServer = local.letsencrypt_server
            storage = {
              kubernetes = true
            }
            dnsChallenge = {
              provider         = "cloudflare"
              resolvers        = ["1.1.1.1:53", "1.0.0.1:53"]
              delayBeforeCheck = 20
            }
          }
        }
        }) : jsonencode({
        cf = {
          acme = {
            email    = "zaid@traefik.io"
            storage  = "/data/acme.json"
            caServer = local.letsencrypt_server
            dnsChallenge = {
              provider         = "cloudflare"
              resolvers        = ["1.1.1.1:53", "1.0.0.1:53"]
              delayBeforeCheck = 20
            }
          }
        }
      })
    ) : null

    ingressRoute = {
      dashboard = {
        enabled     = var.enable_dashboard
        matchRule   = var.dashboard_match_rule != "" ? var.dashboard_match_rule : (local.dns_domain != "" ? "Host(`dashboard.${local.dns_domain}`)" : "PathPrefix(`/dashboard`) || PathPrefix(`/api`)")
        entryPoints = var.dashboard_entrypoints
      }
    }
  }
}
