# demos/unified-ingress

The dominant real-world shape: **one "transit" parent cluster + one "app-workload"
child**, with Traefik Hub multicluster routing through transit and OTel
observability on both. On k3d the two clusters share one host, so the child's Hub
uplink is exposed on host port 9443 and the parent reaches it at
`host.k3d.internal:9443`.

## What it proves

- Traefik Hub in multicluster-parent mode discovers a child cluster's services and
  serves them on the single transit entrypoint.
- A workload that lives only on the app-workload child is reachable through the
  transit cluster.
- The OTel collector on transit receives traces/metrics/access-logs from both
  Traefik installs.

## How it works

The child advertises `whoami` over a named **uplink** (`app-workload`): the whoami
module emits an `Uplink` CRD (`exposeName: app-workload`) plus an IngressRoute
annotated `hub.traefik.io/router.uplinks: app-workload` that matches by path (no
`entryPoints` — Hub attaches it to the uplink). The parent dials that uplink via
`multicluster_provider.children["app-workload"].address` and has its **own**
IngressRoute that terminates `Host(whoami.<domain>)` on `websecure` and forwards to
the remote service `app-workload@multicluster`. Both halves are required: drop the
parent route and the host 404s; the child route alone is never served on a transit
entrypoint.

## Prerequisites

`terraform`, `k3d`, `kubectl`, and a **Traefik Hub token** (offline JWT) in
`terraform.tfvars`. Get one at <https://hub.traefik.io>.

## Run it

```bash
cp terraform.tfvars.example terraform.tfvars   # set domain + traefik_hub_token
make up
make scenarios
make down
```

`make scenarios` curls `https://whoami.<domain>/` through the **transit** host
(:443) and asserts 200 — which only succeeds if cross-cluster discovery worked.

Outputs:
- `transit_dashboard_url` — the transit Traefik dashboard
- `whoami_url` — the child workload, served via transit

## Extending

- **Add more app-workload clusters** — copy the `app_workload_cluster` +
  `app_workload_traefik` blocks, add an entry under the parent's
  `multicluster_provider.children`, expose a new uplink port, and add a matching
  parent IngressRoute.
- **Add an AI workload** — swap the `apps/whoami/k8s` block for `ai/ollama/k8s` or
  similar; or see [`../ai-gateway-openai`](../ai-gateway-openai).

## Sourced from

Extracted from sampled real demos (`aws-unified-ingress`, `k3d-unified-ingress`,
`lke-unified-ingress`, `nutanix-unified-ingress`). Variations across clouds are
minimal — only the `compute/<cloud>` module differs.
