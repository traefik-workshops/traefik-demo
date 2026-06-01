# Parent (EKS hub) routes for the spokes. Each terminates Host(`<host>.<domain>`)
# on the hub websecure entrypoint and forwards to `<exposeName>@multicluster` —
# the Hub multicluster provider reference to a service the spoke advertises over
# its uplink. Without a parent route, the discovered child service has no public
# router and the host 404s. (EC2 / ECS routes are added in their phase.)

locals {
  # host (under var.domain)  ->  the spoke's uplink exposeName
  spoke_routes = merge({
    aks = { host = "aks", service = "aks@multicluster" }     # whoami on AKS
    ai  = { host = "ai", service = "aks-ai@multicluster" }   # AI gateway on AKS
    mcp = { host = "mcp", service = "aks-mcp@multicluster" } # MCP inspector on AKS
    }, var.enable_vm_spokes ? {
    ec2 = { host = "ec2", service = "ec2@multicluster" } # whoami on EC2 (VM)
    ecs = { host = "ecs", service = "ecs@multicluster" } # whoami on ECS (Fargate)
  } : {})
}

resource "kubectl_manifest" "spoke_route" {
  for_each   = local.spoke_routes
  provider   = kubectl.eks
  depends_on = [module.traefik]

  yaml_body = yamlencode({
    apiVersion = "traefik.io/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      name      = "${each.key}-route"
      namespace = kubernetes_namespace_v1.traefik.metadata[0].name
    }
    spec = {
      entryPoints = ["websecure"]
      routes = [{
        kind     = "Rule"
        match    = "Host(`${each.value.host}.${var.domain}`)"
        services = [{ kind = "TraefikService", name = each.value.service }]
      }]
    }
  })
}
