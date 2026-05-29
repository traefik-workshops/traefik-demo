# observability/opentelemetry/k8s

Deploys the OpenTelemetry Collector via Helm, configured with per-backend pipelines (Prometheus, Loki, Tempo, New Relic, Dash0, Honeycomb, LangSmith, Langfuse).

## Example usage

```hcl
module "otel" {
  source = "git::https://github.com/traefik/traefik-demo.git//terraform/observability/opentelemetry/k8s?ref=v4.0.0"

  name             = "opentelemetry"
  namespace        = "traefik-observability"
  enable_prometheus = true
}
```

## Prerequisites

- A working Kubernetes cluster with `helm` and `kubernetes` providers configured.
- Whichever backends you enable must already be reachable from the cluster.

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
| [helm_release.opentelemetry](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_dash0_auth_token"></a> [dash0\_auth\_token](#input\_dash0\_auth\_token) | Dash0 auth token | `string` | `""` | no |
| <a name="input_dash0_dataset"></a> [dash0\_dataset](#input\_dash0\_dataset) | Dash0 dataset | `string` | `""` | no |
| <a name="input_dash0_endpoint"></a> [dash0\_endpoint](#input\_dash0\_endpoint) | Dash0 endpoint | `string` | `""` | no |
| <a name="input_enable_dash0"></a> [enable\_dash0](#input\_enable\_dash0) | Enable Dash0 observability module | `bool` | `false` | no |
| <a name="input_enable_honeycomb"></a> [enable\_honeycomb](#input\_enable\_honeycomb) | Enable Honeycomb observability module | `bool` | `false` | no |
| <a name="input_enable_langfuse"></a> [enable\_langfuse](#input\_enable\_langfuse) | Enable Langfuse trace export (SaaS cloud.langfuse.com or self-hosted). Langfuse's OTLP endpoint currently accepts traces only (metrics/logs in preview); we only wire the traces pipeline here. | `bool` | `false` | no |
| <a name="input_enable_langsmith"></a> [enable\_langsmith](#input\_enable\_langsmith) | Enable LangSmith trace export. LangSmith's OTLP endpoint ingests traces only — metrics and logs are not accepted and will not be exported there. | `bool` | `false` | no |
| <a name="input_enable_loki"></a> [enable\_loki](#input\_enable\_loki) | Enable Grafana Loki observability module | `bool` | `false` | no |
| <a name="input_enable_new_relic"></a> [enable\_new\_relic](#input\_enable\_new\_relic) | Enable New Relic observability module | `bool` | `false` | no |
| <a name="input_enable_prometheus"></a> [enable\_prometheus](#input\_enable\_prometheus) | Enable Prometheus observability module | `bool` | `false` | no |
| <a name="input_enable_tempo"></a> [enable\_tempo](#input\_enable\_tempo) | Enable Grafana Tempo observability module | `bool` | `false` | no |
| <a name="input_honeycomb_api_key"></a> [honeycomb\_api\_key](#input\_honeycomb\_api\_key) | Honeycomb API key | `string` | `""` | no |
| <a name="input_honeycomb_dataset"></a> [honeycomb\_dataset](#input\_honeycomb\_dataset) | Honeycomb dataset | `string` | `""` | no |
| <a name="input_honeycomb_endpoint"></a> [honeycomb\_endpoint](#input\_honeycomb\_endpoint) | Honeycomb endpoint | `string` | `""` | no |
| <a name="input_ingress"></a> [ingress](#input\_ingress) | Enable Ingress for the OpenTelemetry deployment. | `bool` | `false` | no |
| <a name="input_ingress_annotations"></a> [ingress\_annotations](#input\_ingress\_annotations) | Additional metadata annotations merged onto the Ingress. Useful for custom router options beyond the three observability toggles. | `map(string)` | `{}` | no |
| <a name="input_ingress_domain"></a> [ingress\_domain](#input\_ingress\_domain) | The domain for the ingress, default is `cloud` | `string` | `"cloud"` | no |
| <a name="input_ingress_entrypoint"></a> [ingress\_entrypoint](#input\_ingress\_entrypoint) | The entrypoint to use for the ingress, default is `traefik` | `string` | `"traefik"` | no |
| <a name="input_ingress_observability"></a> [ingress\_observability](#input\_ingress\_observability) | Emit Traefik observability signals (access logs, metrics, traces) for the OTLP collector router. Default is false because tracing the collector's own ingest endpoint creates an obvious feedback loop. Same switch shape as observability/langfuse/k8s. | `bool` | `false` | no |
| <a name="input_langfuse_endpoint"></a> [langfuse\_endpoint](#input\_langfuse\_endpoint) | Langfuse OTLP base URL. SaaS US: https://us.cloud.langfuse.com/api/public/otel. EU: https://cloud.langfuse.com/api/public/otel. Self-hosted: https://<host>/api/public/otel. | `string` | `"https://us.cloud.langfuse.com/api/public/otel"` | no |
| <a name="input_langfuse_public_key"></a> [langfuse\_public\_key](#input\_langfuse\_public\_key) | Langfuse public key (pk-lf-...). Pairs with langfuse\_secret\_key as HTTP Basic auth. | `string` | `""` | no |
| <a name="input_langfuse_secret_key"></a> [langfuse\_secret\_key](#input\_langfuse\_secret\_key) | Langfuse secret key (sk-lf-...). Pairs with langfuse\_public\_key as HTTP Basic auth. | `string` | `""` | no |
| <a name="input_langsmith_api_key"></a> [langsmith\_api\_key](#input\_langsmith\_api\_key) | LangSmith API key | `string` | `""` | no |
| <a name="input_langsmith_endpoint"></a> [langsmith\_endpoint](#input\_langsmith\_endpoint) | LangSmith OTLP endpoint. Use https://api.smith.langchain.com/otel (US), https://eu.api.smith.langchain.com/otel (EU), or https://<self-hosted>/api/v1/otel. | `string` | `"https://api.smith.langchain.com/otel"` | no |
| <a name="input_langsmith_project"></a> [langsmith\_project](#input\_langsmith\_project) | LangSmith project name. All traces from this collector land in this project unless overridden per-span via the Langsmith-Project header. | `string` | `"default"` | no |
| <a name="input_loki_endpoint"></a> [loki\_endpoint](#input\_loki\_endpoint) | Loki endpoint | `string` | `""` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of the opentelemetry release | `string` | `"opentelemetry"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | The namespace of the opentelemetry release | `string` | `"traefik-observability"` | no |
| <a name="input_newrelic_endpoint"></a> [newrelic\_endpoint](#input\_newrelic\_endpoint) | New Relic endpoint | `string` | `""` | no |
| <a name="input_newrelic_license_key"></a> [newrelic\_license\_key](#input\_newrelic\_license\_key) | New Relic license key | `string` | `""` | no |
| <a name="input_prometheus_port"></a> [prometheus\_port](#input\_prometheus\_port) | Prometheus port | `number` | `8889` | no |
| <a name="input_tempo_endpoint"></a> [tempo\_endpoint](#input\_tempo\_endpoint) | Tempo endpoint | `string` | `""` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
