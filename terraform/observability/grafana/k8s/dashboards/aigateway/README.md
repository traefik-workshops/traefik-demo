# observability/grafana/k8s/dashboards/aigateway

Renders the AI-Gateway Grafana dashboard JSON as a Kubernetes ConfigMap. Intentionally a "dashboard fragment" module — no Helm release, no provider declarations.

## Example usage

```hcl
module "aigateway_dashboard" {
  source = "git::https://github.com/traefik/terraform-demo-modules.git//terraform/observability/grafana/k8s/dashboards/aigateway?ref=v3.2.0"

  name      = "grafana-dashboard-aigateway"
  namespace = "observability"
}
```

## Prerequisites

- A working Kubernetes cluster with the `kubernetes` provider configured.
- A Grafana deployment configured to pick up dashboard ConfigMaps via the dashboard sidecar.

## Notes

- See **DASH-01** and **PROV-01** in [../../../../../ISSUES.md](../../../../../ISSUES.md).

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
