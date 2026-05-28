# Agent guide — `terraform/observability/`

Inherits from [`../../AGENTS.md`](../../AGENTS.md).

## Scope

Metrics, logs, traces stacks. AI-specific observability (Langfuse) also lives here.

## Modules in this section

Live-derived; regenerate with `make discover | jq '.modules[] | select(.path | startswith("terraform/observability/"))'`.

| Module | Purpose |
|---|---|
| [`grafana/k8s`](./grafana/k8s) | Grafana via Helm — wired Prometheus/Tempo/Loki datasources, optional Traefik ingress, image renderer, demo dashboards. |
| [`grafana/k8s/dashboards/aigateway`](./grafana/k8s/dashboards/aigateway) | AI Gateway dashboard JSON as a ConfigMap (no Helm release, no providers — pure fragment). |
| [`grafana-loki/k8s`](./grafana-loki/k8s) | Grafana Loki via Helm. |
| [`grafana-stack/k8s`](./grafana-stack/k8s) | Full Grafana + Prometheus stack (kube-prometheus-stack) + optional ingress + demo dashboards. |
| [`grafana-tempo/k8s`](./grafana-tempo/k8s) | Grafana Tempo via Helm. |
| [`langfuse/k8s`](./langfuse/k8s) | Langfuse (LLM observability) via Helm with headless org/project/admin seeding + optional Traefik IngressRoute. |
| [`opentelemetry/k8s`](./opentelemetry/k8s) | OpenTelemetry Collector via Helm with per-backend pipelines (Prometheus, Loki, Tempo, New Relic, Dash0, Honeycomb, LangSmith, Langfuse). |
| [`prometheus/k8s`](./prometheus/k8s) | Prometheus via Helm (kube-prometheus-stack) + optional Traefik scrape job + ingress. |

## Sub-conventions

- **Helm-based, k8s-only.** No multi-platform branches.
- **Dashboards as data, not modules.** New dashboards go under `grafana/k8s/dashboards/<topic>/` as JSON + a tiny `dashboards.tf` that wires them into Grafana via ConfigMap labels.
- **Scrape-target wiring** (e.g. Prometheus picking up Traefik metrics) is configured *here*, not in the target's module. The target exposes a `metrics_*` output; the observability module accepts it as a variable.

## Required outputs (when added)

- `prometheus/k8s`: `endpoint`, `service_name`
- `grafana/k8s`: `endpoint`, `admin_user`, `admin_password` (sensitive)
- `langfuse/k8s`: already has good outputs (`public_key`, `secret_key`, `otel_endpoint`, `admin_*`) — pattern for others to follow.

## Don't

- Don't put metrics-scraping config on the *target* (e.g. inside the Traefik module). The pattern is: target exposes `metrics_*` info; observability consumes it.
- Don't create one module per backend variant. `grafana-stack` is the umbrella; individual modules exist for selective installs only.
