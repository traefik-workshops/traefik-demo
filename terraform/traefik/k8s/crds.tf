
resource "null_resource" "traefik_crds" {
  count = var.skip_crds ? 0 : 1

  triggers = {
    chart_version = "1.16.0"
    gateway_api   = tostring(!var.skip_gateway_api_crds)
    hub           = tostring(var.enable_api_gateway || var.enable_api_management)
  }

  provisioner "local-exec" {
    # Target a specific cluster when given a kubeconfig (e.g. a cluster created
    # in this same run, so there's no current context yet); otherwise fall back
    # to the ambient kubeconfig / current context.
    environment = var.kubeconfig != "" ? { KUBECONFIG = var.kubeconfig } : {}
    command     = <<-EOT
      helm repo add traefik https://traefik.github.io/charts --force-update
      helm template traefik-crds traefik/traefik-crds \
        --version 1.16.0 \
        --set gatewayAPI=${var.skip_gateway_api_crds ? "false" : "true"} \
        --set knative=false \
        --set hub=${var.enable_api_gateway || var.enable_api_management ? "true" : "false"} | kubectl apply --server-side --force-conflicts -f -
    EOT
  }
}
