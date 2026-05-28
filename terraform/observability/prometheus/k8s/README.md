# observability/prometheus/k8s

Deploys Prometheus on Kubernetes via Helm (kube-prometheus-stack), with an optional Traefik scrape job and ingress.

## Example usage

```hcl
module "prometheus" {
  source = "git::https://github.com/traefik/traefik-demo.git//terraform/observability/prometheus/k8s?ref=v4.0.0"

  name      = "prometheus"
  namespace = "observability"
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
| `helm_release.prometheus` | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| namespace | Namespace for the Prometheus deployment | `string` | n/a | yes |
| extra_values | Extra values to pass to the Prometheus deployment. | `any` | `{}` | no |
| ingress | Enable Ingress for the Prometheus deployment. | `bool` | `false` | no |
| ingress_annotations | Additional metadata annotations merged onto the Ingress. Useful for custom router options beyond the three observability toggles. | `map(string)` | `{}` | no |
| ingress_domain | The domain for the ingress, default is `cloud` | `string` | `"cloud"` | no |
| ingress_entrypoint | The entrypoint to use for the ingress, default is `traefik` | `string` | `"traefik"` | no |
| ingress_observability | Emit Traefik observability signals (access logs, metrics, traces) for the Prometheus ingress router. Set to false to add the three `traefik.ingress.kubernetes.io/router.observability.*: "false"` annotations. Same switch shape as other observability/k8s modules. | `bool` | `true` | no |
| name | The name of the prometheus release | `string` | `"prometheus"` | no |
| tolerations | Tolerations for the Prometheus deployment. | `list(object({key = string, operator = string, value = string, effect = string))` | `[]` | no |
| traefik_metrics_job_metrics_path | Metrics path for the Traefik metrics job | `string` | `"/metrics"` | no |
| traefik_metrics_job_url | URL for the Traefik metrics job | `string` | `""` | no |

<!-- END_TF_DOCS -->
