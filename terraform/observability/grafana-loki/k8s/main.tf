resource "helm_release" "loki" {
  name       = var.name
  namespace  = var.namespace
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki"
  version    = "v6.42.0"
  timeout    = 900
  atomic     = true

  values = [
    yamlencode({
      deploymentMode = "SingleBinary"
      singleBinary = {
        replicas = 1
      }
      loki = {
        commonConfig = {
          replication_factor = 1
        }
        schemaConfig = {
          configs = [{
            from         = "2024-04-01"
            store        = "tsdb"
            object_store = "s3"
            schema       = "v13"
            index = {
              prefix = "loki_index_"
              period = "24h"
            }
          }]
        }
        pattern_ingester = {
          enabled = true
        }
        limits_config = {
          allow_structured_metadata = true
          volume_enabled            = true
        }
        ruler = {
          enable_api = true
        }
      }
      minio = {
        enabled = true
      }
      lokiCanary = {
        enabled = false
      }
      test = {
        enabled = false
      }
      gateway = {
        enabled = false
      }
      ingester = {
        replicas = 0
      }
      querier = {
        replicas = 0
      }
      queryFrontend = {
        replicas = 0
      }
      queryScheduler = {
        replicas = 0
      }
      distributor = {
        replicas = 0
      }
      compactor = {
        replicas = 0
      }
      indexGateway = {
        replicas = 0
      }
      bloomCompactor = {
        replicas = 0
      }
      bloomGateway = {
        replicas = 0
      }
      write = {
        replicas = 0
      }
      read = {
        replicas = 0
      }
      backend = {
        replicas = 0
      }
      chunksCache = {
        enabled = false
      }
    }),
    yamlencode(var.extra_values)
  ]

  set = [
    {
      name  = "loki.auth_enabled"
      value = false
    }
  ]
}
