# observability/grafana/k8s

Deploys Grafana on Kubernetes via Helm, with wired Prometheus / Tempo / Loki datasources, optional Traefik ingress, optional image renderer, and toggleable demo dashboards.

## Example usage

```hcl
module "grafana" {
  source = "git::https://github.com/traefik/terraform-demo-modules.git//terraform/observability/grafana/k8s?ref=v3.2.0"

  name       = "grafana"
  namespace  = "observability"
  prometheus = { enabled = true,  url = { override = "", service = "prometheus", port = 9090, namespace = "observability" } }
  tempo      = { enabled = false, url = { override = "", service = "tempo",      port = 3100, namespace = "observability" } }
  loki       = { enabled = false, url = { override = "", service = "loki",       port = 3100, namespace = "observability" } }
  dashboards = { aigateway = true, mcpgateway = false, apim = false }
}
```

## Prerequisites

- A working Kubernetes cluster with the `helm` provider configured.
- Traefik installed in-cluster if `ingress = true`.

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name | Version |
|------|---------|
| helm | ~> 3.0 |

## Providers

| Name | Source | Version |
|------|--------|---------|
| helm | `hashicorp/helm` | `~> 3.0` |

## Resources

| Name | Type |
|------|------|
| `helm_release.grafana` | resource |
| `kubernetes_config_map_v1.extra_dashboards` | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| dashboards | n/a | `object({aigateway = bool, mcpgateway = bool, apim = bool)` | n/a | yes |
| loki | Loki datasource configuration. | `object({enabled = bool, url = object({override = string, service = string, port = number, namespace = string))` | n/a | yes |
| namespace | Namespace for the Grafana deployment | `string` | n/a | yes |
| prometheus | Prometheus datasource configuration. | `object({enabled = bool, url = object({override = string, service = string, port = number, namespace = string))` | n/a | yes |
| tempo | Tempo datasource configuration. | `object({enabled = bool, url = object({override = string, service = string, port = number, namespace = string))` | n/a | yes |
| extra_dashboards | A map of dashboard names to their JSON content. | `map(string)` | `{}` | no |
| extra_values | Extra values to pass to the Grafana deployment. | `any` | `{}` | no |
| image_renderer | Enable the Grafana Image Renderer plugin for PNG export of panels and dashboards. | `bool` | `false` | no |
| ingress | Enable Ingress for the Grafana deployment. | `bool` | `false` | no |
| ingress_annotations | Additional metadata annotations merged onto the Ingress. Useful for custom router options beyond the three observability toggles. | `map(string)` | `{}` | no |
| ingress_domain | The domain for the ingress, default is `cloud` | `string` | `"cloud"` | no |
| ingress_entrypoint | The entrypoint to use for the ingress, default is `traefik` | `string` | `"traefik"` | no |
| ingress_observability | Emit Traefik observability signals (access logs, metrics, traces) for the Grafana ingress router. Set to false to add the three `traefik.ingress.kubernetes.io/router.observability.*: "false"` annotations. Same switch shape as other observability/k8s modules. | `bool` | `true` | no |
| name | The name of the grafana release | `string` | `"grafana"` | no |
| tolerations | Tolerations for the Grafana deployment. | `list(object({key = string, operator = string, value = string, effect = string))` | `[]` | no |

<!-- END_TF_DOCS -->
