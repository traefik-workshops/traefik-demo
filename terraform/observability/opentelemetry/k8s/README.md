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
|------|---------|
| helm | ~> 3.0 |
| kubernetes | >= 2.0 |

## Providers

| Name | Source | Version |
|------|--------|---------|
| helm | `hashicorp/helm` | `~> 3.0` |
| kubernetes | `hashicorp/kubernetes` | `>= 2.0` |

## Resources

| Name | Type |
|------|------|
| `helm_release.opentelemetry` | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| dash0_auth_token 🔒 | Dash0 auth token | `string` | `""` | no |
| dash0_dataset | Dash0 dataset | `string` | `""` | no |
| dash0_endpoint | Dash0 endpoint | `string` | `""` | no |
| enable_dash0 | Enable Dash0 observability module | `bool` | `false` | no |
| enable_honeycomb | Enable Honeycomb observability module | `bool` | `false` | no |
| enable_langfuse | Enable Langfuse trace export (SaaS cloud.langfuse.com or self-hosted). Langfuse's OTLP endpoint currently accepts traces only (metrics/logs in preview); we only wire the traces pipeline here. | `bool` | `false` | no |
| enable_langsmith | Enable LangSmith trace export. LangSmith's OTLP endpoint ingests traces only — metrics and logs are not accepted and will not be exported there. | `bool` | `false` | no |
| enable_loki | Enable Grafana Loki observability module | `bool` | `false` | no |
| enable_new_relic | Enable New Relic observability module | `bool` | `false` | no |
| enable_prometheus | Enable Prometheus observability module | `bool` | `false` | no |
| enable_tempo | Enable Grafana Tempo observability module | `bool` | `false` | no |
| honeycomb_api_key 🔒 | Honeycomb API key | `string` | `""` | no |
| honeycomb_dataset | Honeycomb dataset | `string` | `""` | no |
| honeycomb_endpoint | Honeycomb endpoint | `string` | `""` | no |
| ingress | Enable Ingress for the OpenTelemetry deployment. | `bool` | `false` | no |
| ingress_annotations | Additional metadata annotations merged onto the Ingress. Useful for custom router options beyond the three observability toggles. | `map(string)` | `{}` | no |
| ingress_domain | The domain for the ingress, default is `cloud` | `string` | `"cloud"` | no |
| ingress_entrypoint | The entrypoint to use for the ingress, default is `traefik` | `string` | `"traefik"` | no |
| ingress_observability | Emit Traefik observability signals (access logs, metrics, traces) for the OTLP collector router. Default is false because tracing the collector's own ingest endpoint creates an obvious feedback loop. Same switch shape as observability/langfuse/k8s. | `bool` | `false` | no |
| langfuse_endpoint | Langfuse OTLP base URL. SaaS US: https://us.cloud.langfuse.com/api/public/otel. EU: https://cloud.langfuse.com/api/public/otel. Self-hosted: https://<host>/api/public/otel. | `string` | `"https://us.cloud.langfuse.com/api/public/otel"` | no |
| langfuse_public_key 🔒 | Langfuse public key (pk-lf-...). Pairs with langfuse_secret_key as HTTP Basic auth. | `string` | `""` | no |
| langfuse_secret_key 🔒 | Langfuse secret key (sk-lf-...). Pairs with langfuse_public_key as HTTP Basic auth. | `string` | `""` | no |
| langsmith_api_key 🔒 | LangSmith API key | `string` | `""` | no |
| langsmith_endpoint | LangSmith OTLP endpoint. Use https://api.smith.langchain.com/otel (US), https://eu.api.smith.langchain.com/otel (EU), or https://<self-hosted>/api/v1/otel. | `string` | `"https://api.smith.langchain.com/otel"` | no |
| langsmith_project | LangSmith project name. All traces from this collector land in this project unless overridden per-span via the Langsmith-Project header. | `string` | `"default"` | no |
| loki_endpoint | Loki endpoint | `string` | `""` | no |
| name | The name of the opentelemetry release | `string` | `"opentelemetry"` | no |
| namespace | The namespace of the opentelemetry release | `string` | `"traefik-observability"` | no |
| newrelic_endpoint | New Relic endpoint | `string` | `""` | no |
| newrelic_license_key | New Relic license key | `string` | `""` | no |
| prometheus_port | Prometheus port | `number` | `8889` | no |
| tempo_endpoint | Tempo endpoint | `string` | `""` | no |

<!-- END_TF_DOCS -->
