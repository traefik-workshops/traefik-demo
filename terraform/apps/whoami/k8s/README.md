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
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_kubectl"></a> [kubectl](#requirement\_kubectl) | >= 1.14 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_kubectl"></a> [kubectl](#provider\_kubectl) | >= 1.14 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | ~> 2.0 |

## Resources

| Name | Type |
| ---- | ---- |
| [kubectl_manifest.ingress_route](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/resources/manifest) | resource |
| [kubectl_manifest.middleware_strip_prefix](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/resources/manifest) | resource |
| [kubectl_manifest.uplink](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/resources/manifest) | resource |
| [kubernetes_deployment_v1.echo](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/deployment_v1) | resource |
| [kubernetes_service_v1.echo](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_v1) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_apps"></a> [apps](#input\_apps) | Map of applications to deploy to Kubernetes. Each app can have multiple replicas. | <pre>map(object({<br/>    replicas     = optional(number, 1)<br/>    port         = optional(number, 80)<br/>    docker_image = optional(string, "traefik/whoami:latest")<br/>    labels       = optional(map(string), {})<br/>    ingress_route = optional(object({<br/>      enabled     = optional(bool, false)<br/>      host        = optional(string)<br/>      entrypoints = optional(list(string), ["web"])<br/>      middlewares = optional(list(object({<br/>        name      = string<br/>        namespace = optional(string)<br/>      })), [])<br/>      strip_prefix = optional(object({<br/>        enabled  = optional(bool, false)<br/>        prefixes = optional(list(string), [])<br/>      }), {})<br/>    }), {})<br/>  }))</pre> | `{}` | no |
| <a name="input_common_labels"></a> [common\_labels](#input\_common\_labels) | Common labels to apply to all resources | `map(string)` | `{}` | no |
| <a name="input_ingress_annotations"></a> [ingress\_annotations](#input\_ingress\_annotations) | Additional metadata annotations merged onto every whoami IngressRoute. Useful for custom router options beyond the three observability toggles. | `map(string)` | `{}` | no |
| <a name="input_ingress_observability"></a> [ingress\_observability](#input\_ingress\_observability) | Emit Traefik observability signals (access logs, metrics, traces) for every whoami IngressRoute this module creates. Set to false to add the three `traefik.ingress.kubernetes.io/router.observability.*: "false"` annotations. Same switch shape as other k8s modules. | `bool` | `true` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Kubernetes namespace to deploy applications | `string` | `"apps"` | no |
| <a name="input_node_selector"></a> [node\_selector](#input\_node\_selector) | Node selector for pod scheduling | `map(string)` | `{}` | no |
| <a name="input_uplink_enabled"></a> [uplink\_enabled](#input\_uplink\_enabled) | Advertise the route over a Traefik Hub multicluster uplink instead of serving it locally. When true the IngressRoute drops entryPoints and matches PathPrefix(`/`) (Hub attaches it to the uplink), so ingress\_route.host and ingress\_route.strip\_prefix are IGNORED for matching — the parent cluster owns the Host match. Supports at most one app with ingress\_route.enabled (one Uplink is shared). Requires uplink\_name. | `bool` | `false` | no |
| <a name="input_uplink_name"></a> [uplink\_name](#input\_uplink\_name) | Uplink name to advertise on. Required when uplink\_enabled. Must match the child's --hub.uplinkEntryPoints.<name> entrypoint and the parent's <name>@multicluster service ref. | `string` | `""` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_deployments"></a> [deployments](#output\_deployments) | Map of all Kubernetes deployments |
| <a name="output_services"></a> [services](#output\_services) | Map of all Kubernetes services |
<!-- END_TF_DOCS -->
