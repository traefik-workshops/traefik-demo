# observability/grafana/k8s/dashboards/aigateway

> **Status:** dashboard fragment. Not a conventional module — emits a single Kubernetes ConfigMap that Grafana's dashboard sidecar picks up. Kept under `dashboards/<topic>/` to mirror the file layout consumers expect.

Renders the AI-Gateway Grafana dashboard JSON as a Kubernetes ConfigMap. Intentionally a "dashboard fragment" module — no Helm release, no provider declarations.

## Example usage

```hcl
module "aigateway_dashboard" {
  source = "git::https://github.com/traefik/traefik-demo.git//terraform/observability/grafana/k8s/dashboards/aigateway?ref=v4.0.0"

  name      = "grafana-dashboard-aigateway"
  namespace = "observability"
}
```

## Prerequisites

- A working Kubernetes cluster with the `kubernetes` provider configured.
- A Grafana deployment configured to pick up dashboard ConfigMaps via the dashboard sidecar.

## Notes

<!-- BEGIN_TF_DOCS -->


## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2.27 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | ~> 2.27 |

## Resources

| Name | Type |
| ---- | ---- |
| [kubernetes_config_map_v1.grafana_aigateway_dashboards](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map_v1) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_name"></a> [name](#input\_name) | Name of the ConfigMap holding the AI Gateway dashboard JSON (Grafana's sidecar picks it up by label). | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace to create the dashboard ConfigMap in — usually the namespace Grafana watches for dashboard ConfigMaps. | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
