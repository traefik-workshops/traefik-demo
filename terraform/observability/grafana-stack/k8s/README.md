# observability/grafana-stack/k8s

Deploys a full Grafana + Prometheus stack (kube-prometheus-stack) with optional Traefik ingress and demo dashboards.

## Example usage

```hcl
module "grafana_stack" {
  source = "git::https://github.com/traefik/traefik-demo.git//terraform/observability/grafana-stack/k8s?ref=v4.0.0"

  namespace  = "observability"
  dashboards = { aigateway = true, mcpgateway = false, apim = false }
}
```

## Prerequisites

- A working Kubernetes cluster with `helm` and `kubernetes` providers configured.
- Traefik installed in-cluster if `ingress = true`.

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name | Version |
|------|---------|
| helm | ~> 3.0 |
| kubernetes | >= 2.0 |

## Providers

| Name | Source | Version |
|------|--------|---------|
| helm | `hashicorp/helm` | `~> 3.0` |
| kubernetes | `hashicorp/kubernetes` | `>= 2.0` |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| dashboards | n/a | `object({aigateway = bool, mcpgateway = bool, apim = bool)` | n/a | yes |
| namespace | Namespace for the Grafana deployment | `string` | n/a | yes |
| extra_dashboards | A map of dashboard names to their JSON content. | `map(string)` | `{}` | no |
| grafana_extra_values | Extra values to pass to the Grafana deployment. | `any` | `{}` | no |
| ingress | Enable Ingress for the Grafana deployment. | `bool` | `false` | no |
| ingress_annotations | Additional metadata annotations merged onto each child module's Ingress. Useful for custom router options beyond the three observability toggles. | `map(string)` | `{}` | no |
| ingress_domain | The domain for the ingress, default is `cloud` | `string` | `"cloud"` | no |
| ingress_entrypoint | The entrypoint to use for the ingress, default is `traefik` | `string` | `"traefik"` | no |
| ingress_observability | Emit Traefik observability signals (access logs, metrics, traces) for the stack's Prometheus and Grafana ingress routers. Set to false to add the three `traefik.ingress.kubernetes.io/router.observability.*: "false"` annotations on each child module. Same switch shape as other observability/k8s modules. | `bool` | `true` | no |
| metrics_host | Host of metrics endpoint | `string` | `""` | no |
| metrics_port | Port of metrics endpoint | `number` | `8889` | no |
| prometheus_extra_values | Extra values to pass to the Prometheus deployment. | `any` | `{}` | no |
| prometheus_url_override | If non-empty, Grafana's Prometheus datasource URL is set to this value instead of the default kube-prometheus-stack service. Useful when you route queries through a Prom-compatible backend like VictoriaMetrics vmselect. | `string` | `""` | no |
| tolerations | Tolerations for the Grafana deployment. | `list(object({key = string, operator = string, value = string, effect = string))` | `[]` | no |

<!-- END_TF_DOCS -->
