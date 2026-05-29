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
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | ~> 3.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_helm"></a> [helm](#provider\_helm) | ~> 3.0 |

## Resources

| Name | Type |
| ---- | ---- |
| [helm_release.prometheus](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace for the Prometheus deployment | `string` | n/a | yes |
| <a name="input_extra_values"></a> [extra\_values](#input\_extra\_values) | Extra values to pass to the Prometheus deployment. | `any` | `{}` | no |
| <a name="input_ingress"></a> [ingress](#input\_ingress) | Enable Ingress for the Prometheus deployment. | `bool` | `false` | no |
| <a name="input_ingress_annotations"></a> [ingress\_annotations](#input\_ingress\_annotations) | Additional metadata annotations merged onto the Ingress. Useful for custom router options beyond the three observability toggles. | `map(string)` | `{}` | no |
| <a name="input_ingress_domain"></a> [ingress\_domain](#input\_ingress\_domain) | The domain for the ingress, default is `cloud` | `string` | `"cloud"` | no |
| <a name="input_ingress_entrypoint"></a> [ingress\_entrypoint](#input\_ingress\_entrypoint) | The entrypoint to use for the ingress, default is `traefik` | `string` | `"traefik"` | no |
| <a name="input_ingress_observability"></a> [ingress\_observability](#input\_ingress\_observability) | Emit Traefik observability signals (access logs, metrics, traces) for the Prometheus ingress router. Set to false to add the three `traefik.ingress.kubernetes.io/router.observability.*: "false"` annotations. Same switch shape as other observability/k8s modules. | `bool` | `true` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of the prometheus release | `string` | `"prometheus"` | no |
| <a name="input_tolerations"></a> [tolerations](#input\_tolerations) | Tolerations for the Prometheus deployment. | <pre>list(object({<br/>    key      = string<br/>    operator = string<br/>    value    = string<br/>    effect   = string<br/>  }))</pre> | `[]` | no |
| <a name="input_traefik_metrics_job_metrics_path"></a> [traefik\_metrics\_job\_metrics\_path](#input\_traefik\_metrics\_job\_metrics\_path) | Metrics path for the Traefik metrics job | `string` | `"/metrics"` | no |
| <a name="input_traefik_metrics_job_url"></a> [traefik\_metrics\_job\_url](#input\_traefik\_metrics\_job\_url) | URL for the Traefik metrics job | `string` | `""` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_namespace"></a> [namespace](#output\_namespace) | Namespace the Prometheus release is installed into. |
| <a name="output_service_endpoint"></a> [service\_endpoint](#output\_service\_endpoint) | In-cluster Prometheus service URL (uses port 9090 by default). |
<!-- END_TF_DOCS -->
