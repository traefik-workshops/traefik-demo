resource "kubectl_manifest" "aigateway_traffic_testrun" {
  yaml_body = yamlencode({
    apiVersion = "k6.io/v1alpha1"
    kind       = "TestRun"
    metadata = {
      name = "aigateway-traffic"
      labels = {
        app         = "aigateway-load-test"
        "test-type" = "semantic-cache-demo"
      }
    }
    spec = {
      parallelism = 1
      separate    = false
      quiet       = "false"
      arguments   = "--tag testid=aigateway-traffic --env SCENARIO=aigateway-traffic"
      initializer = {
        metadata = {
          labels = {
            initializer = "k6"
          }
        }
      }
      script = {
        configMap = {
          name = "aigateway-traffic"
          file = "load.js"
        }
      }
    }
  })

  depends_on = [kubectl_manifest.aigateway_traffic_configmap]
}
