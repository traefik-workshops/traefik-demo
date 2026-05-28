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

## Resources

| Name | Type |
|------|------|
| `kubernetes_config_map_v1.grafana_aigateway_dashboards` | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | n/a | `string` | n/a | yes |
| namespace | n/a | `string` | n/a | yes |

<!-- END_TF_DOCS -->
