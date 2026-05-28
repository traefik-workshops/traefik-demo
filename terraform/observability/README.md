# observability/

Metrics, logs, and traces stacks. All modules here are Kubernetes-based.

## Modules

| Path | Purpose |
|---|---|
| [`prometheus/k8s`](./prometheus/k8s) | Prometheus + scrape configs (incl. Traefik metrics) |
| [`grafana/k8s`](./grafana/k8s) | Grafana with dashboards as ConfigMaps |
| [`grafana/k8s/dashboards/aigateway`](./grafana/k8s/dashboards/aigateway) | Dashboard JSON for the AI gateway (data-only) |
| [`grafana-loki/k8s`](./grafana-loki/k8s) | Loki (logs) |
| [`grafana-tempo/k8s`](./grafana-tempo/k8s) | Tempo (traces) |
| [`grafana-stack/k8s`](./grafana-stack/k8s) | Bundled Grafana + Loki + Tempo + Prometheus |
| [`opentelemetry/k8s`](./opentelemetry/k8s) | OpenTelemetry Collector |
| [`langfuse/k8s`](./langfuse/k8s) | Langfuse (LLM observability) |

## Pick one stack

For most demos, pick **one** of:

- `grafana-stack/k8s` — easiest path; one module installs everything.
- Separate `prometheus`/`grafana`/`grafana-loki`/`grafana-tempo` — when you want to swap a component or already have one of them in the cluster.

Don't install `grafana-stack` *and* the individual modules — you'll get duplicate Prometheus instances scraping each other.

## When to add a new module

- A new observability backend (Datadog Agent, New Relic, ...) — yes, add a module.
- A new Grafana dashboard — *don't* add a new module. Add a JSON file under `grafana/k8s/dashboards/<topic>/` following the `aigateway` pattern.
