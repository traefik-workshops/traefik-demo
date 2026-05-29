# observability/grafana/k8s

Deploys Grafana on Kubernetes via Helm, with wired Prometheus / Tempo / Loki datasources, optional Traefik ingress, optional image renderer, and toggleable demo dashboards.

## Example usage

```hcl
module "grafana" {
  source = "git::https://github.com/traefik/traefik-demo.git//terraform/observability/grafana/k8s?ref=v4.0.0"

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
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | ~> 3.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_helm"></a> [helm](#provider\_helm) | ~> 3.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | ~> 2.0 |

## Resources

| Name | Type |
| ---- | ---- |
| [helm_release.grafana](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_config_map_v1.extra_dashboards](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map_v1) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_dashboards"></a> [dashboards](#input\_dashboards) | Bundled Traefik Hub dashboards to install as ConfigMaps and pre-provision in Grafana. Toggle each topic on/off independently — the AI Gateway, MCP Gateway, and API Management dashboards each pull from their own metrics source. | <pre>object({<br/>    aigateway  = bool<br/>    mcpgateway = bool<br/>    apim       = bool<br/>  })</pre> | n/a | yes |
| <a name="input_loki"></a> [loki](#input\_loki) | Loki datasource provisioned into Grafana when `enabled = true`. URL composition matches the `prometheus` variable. Becomes the default datasource only if both Prometheus and Tempo are disabled. | <pre>object({<br/>    enabled = bool<br/>    url = object({<br/>      override  = string<br/>      service   = string<br/>      port      = number<br/>      namespace = string<br/>    })<br/>  })</pre> | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace for the Grafana deployment | `string` | n/a | yes |
| <a name="input_prometheus"></a> [prometheus](#input\_prometheus) | Prometheus datasource provisioned into Grafana when `enabled = true`. URL is `url.override` if set, otherwise built as `http://<service>.<namespace>.svc:<port>` (namespace optional). Prometheus is the implicit default datasource when present. | <pre>object({<br/>    enabled = bool<br/>    url = object({<br/>      override  = string<br/>      service   = string<br/>      port      = number<br/>      namespace = string<br/>    })<br/>  })</pre> | n/a | yes |
| <a name="input_tempo"></a> [tempo](#input\_tempo) | Tempo datasource provisioned into Grafana when `enabled = true`. URL composition matches the `prometheus` variable. Becomes the default datasource only if Prometheus is disabled. | <pre>object({<br/>    enabled = bool<br/>    url = object({<br/>      override  = string<br/>      service   = string<br/>      port      = number<br/>      namespace = string<br/>    })<br/>  })</pre> | n/a | yes |
| <a name="input_extra_dashboards"></a> [extra\_dashboards](#input\_extra\_dashboards) | A map of dashboard names to their JSON content. | `map(string)` | `{}` | no |
| <a name="input_extra_values"></a> [extra\_values](#input\_extra\_values) | Extra values to pass to the Grafana deployment. | `any` | `{}` | no |
| <a name="input_image_renderer"></a> [image\_renderer](#input\_image\_renderer) | Enable the Grafana Image Renderer plugin for PNG export of panels and dashboards. | `bool` | `false` | no |
| <a name="input_ingress"></a> [ingress](#input\_ingress) | Enable Ingress for the Grafana deployment. | `bool` | `false` | no |
| <a name="input_ingress_annotations"></a> [ingress\_annotations](#input\_ingress\_annotations) | Additional metadata annotations merged onto the Ingress. Useful for custom router options beyond the three observability toggles. | `map(string)` | `{}` | no |
| <a name="input_ingress_domain"></a> [ingress\_domain](#input\_ingress\_domain) | The domain for the ingress, default is `cloud` | `string` | `"cloud"` | no |
| <a name="input_ingress_entrypoint"></a> [ingress\_entrypoint](#input\_ingress\_entrypoint) | The entrypoint to use for the ingress, default is `traefik` | `string` | `"traefik"` | no |
| <a name="input_ingress_observability"></a> [ingress\_observability](#input\_ingress\_observability) | Emit Traefik observability signals (access logs, metrics, traces) for the Grafana ingress router. Set to false to add the three `traefik.ingress.kubernetes.io/router.observability.*: "false"` annotations. Same switch shape as other observability/k8s modules. | `bool` | `true` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of the grafana release | `string` | `"grafana"` | no |
| <a name="input_tolerations"></a> [tolerations](#input\_tolerations) | Tolerations for the Grafana deployment. | <pre>list(object({<br/>    key      = string<br/>    operator = string<br/>    value    = string<br/>    effect   = string<br/>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_namespace"></a> [namespace](#output\_namespace) | Namespace the Grafana release is installed into. |
| <a name="output_service_endpoint"></a> [service\_endpoint](#output\_service\_endpoint) | In-cluster Grafana service URL. |
<!-- END_TF_DOCS -->
