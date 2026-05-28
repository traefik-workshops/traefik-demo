resource "kubectl_manifest" "aigateway_traffic_configmap" {
  yaml_body = yamlencode({
    apiVersion = "v1"
    kind       = "ConfigMap"
    metadata = {
      name = "aigateway-traffic"
    }
    data = {
      "load.js" = templatefile("${path.module}/scenarios/load.js", {
        apis_json              = local.apis_json_escaped
        users_json             = local.users_json_escaped
        keycloak_url           = var.keycloak_url
        keycloak_client_id     = var.keycloak_client_id
        keycloak_client_secret = var.keycloak_client_secret
        min_messages           = var.min_messages_per_conversation
        max_messages           = var.max_messages_per_conversation
      })
    }
  })
}
