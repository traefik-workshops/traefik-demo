# apps/whoami/k8s

Deploys one or more Traefik `whoami` instances on Kubernetes as Deployments + Services, with optional Traefik `IngressRoute`, `Middleware` (strip-prefix), and Traefik Hub `Uplink` resources.

## Example usage

```hcl
module "whoami" {
  source = "git::https://github.com/traefik/traefik-demo.git//terraform/apps/whoami/k8s?ref=v4.0.0"

  namespace = "apps"
  apps = {
    "whoami-a" = {
      replicas = 2
      port     = 80
      ingress_route = {
        enabled = true
        host    = "whoami.demo.traefik.ai"
      }
    }
  }
}
```

## Prerequisites

- A working Kubernetes cluster with `kubernetes` and `kubectl` providers configured.
- Traefik installed in-cluster if `ingress_route.enabled = true` on any app.

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name | Version |
|------|---------|
| kubectl | >= 1.14 |

## Providers

| Name | Source | Version |
|------|--------|---------|
| kubectl | `gavinbunney/kubectl` | `>= 1.14` |

## Resources

| Name | Type |
|------|------|
| `kubernetes_deployment_v1.echo` | resource |
| `kubernetes_service_v1.echo` | resource |
| `kubectl_manifest.middleware_strip_prefix` | resource |
| `kubectl_manifest.uplink` | resource |
| `kubectl_manifest.ingress_route` | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| apps | Map of applications to deploy to Kubernetes. Each app can have multiple replicas. | `map(object({replicas = optional(number, 1), port = optional(number, 80), docker_image = optional(string, "traefik/whoami:latest"), labels = optional(map(string), {), ingress_route = optional(object({enabled = optional(bool, false), host = optional(string), entrypoints = optional(list(string), ["web"]), middlewares = optional(list(object({name = string, namespace = optional(string))), []), strip_prefix = optional(object({enabled = optional(bool, false), prefixes = optional(list(string), [])), {)), {)))` | `{}` | no |
| common_labels | Common labels to apply to all resources | `map(string)` | `{}` | no |
| ingress_annotations | Additional metadata annotations merged onto every whoami IngressRoute. Useful for custom router options beyond the three observability toggles. | `map(string)` | `{}` | no |
| ingress_observability | Emit Traefik observability signals (access logs, metrics, traces) for every whoami IngressRoute this module creates. Set to false to add the three `traefik.ingress.kubernetes.io/router.observability.*: "false"` annotations. Same switch shape as other k8s modules. | `bool` | `true` | no |
| namespace | Kubernetes namespace to deploy applications | `string` | `"apps"` | no |
| node_selector | Node selector for pod scheduling | `map(string)` | `{}` | no |
| uplink_enabled | Advertise the route over a Traefik Hub multicluster uplink instead of serving it locally. When true the IngressRoute drops `entryPoints` and matches `PathPrefix(\`/\`)`, so `ingress_route.host`/`strip_prefix` are ignored for matching (the parent owns the Host). At most one `ingress_route.enabled` app; requires `uplink_name`. | `bool` | `false` | no |
| uplink_name | Uplink name to advertise on. **Required when `uplink_enabled`.** Must match the child's `--hub.uplinkEntryPoints.<name>` entrypoint and the parent's `<name>@multicluster` service ref. | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| deployments | Map of all Kubernetes deployments |
| services | Map of all Kubernetes services |

<!-- END_TF_DOCS -->
