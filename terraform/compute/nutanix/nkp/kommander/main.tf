data "kubernetes_resource" "traefik" {
  api_version = "apps.kommander.d2iq.io/v1alpha3"
  kind        = "AppDeployment"

  metadata {
    name      = "traefik"
    namespace = "kommander"
  }
}

resource "kubectl_manifest" "traefik_overrides" {
  apply_only = true

  yaml_body = yamlencode({
    apiVersion = "v1"
    kind       = "ConfigMap"
    metadata = {
      name      = "traefik-overrides"
      namespace = "kommander"
    }

    data = {
      "values.yaml" = <<-EOT
        providers:
          kubernetesIngress:
            namespaces:
              - kommander
              - kommander-flux
          kubernetesCRD:
            namespaces:
              - kommander
              - kommander-flux
      EOT
    }
  })
}

resource "kubectl_manifest" "traefik_app_deployment" {
  apply_only = true

  yaml_body = <<-EOT
    apiVersion: apps.kommander.d2iq.io/v1alpha3
    kind: AppDeployment
    metadata:
      name: traefik
      namespace: kommander
      annotations:
        terraform.io/force-update: "${timestamp()}"
    spec:
      appRef:
        name: ${data.kubernetes_resource.traefik.object.spec.appRef.name}
        kind: ClusterApp
      configOverrides:
        name: traefik-overrides
  EOT

  depends_on = [kubectl_manifest.traefik_overrides]
}

data "kubernetes_service_v1" "kommander_traefik" {
  metadata {
    name      = "kommander-traefik"
    namespace = "kommander"
  }
}
