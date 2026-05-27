# Agent guide — `terraform/observability/`

Inherits from [`../../CLAUDE.md`](../../CLAUDE.md).

## Scope

Metrics, logs, traces stacks. AI-specific observability (Langfuse) also lives here.

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
