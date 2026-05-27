# demos/

Reference compositions. **These are not real demos** — they are minimal, sanitized examples that show how the modules and charts in this repo compose together. Real demos live in their own repos (`ai-demo/`, `*-unified-ingress/`, `clients/*/`).

Use these to:

- Pattern-match when building a new demo. Find the archetype that's closest to what you need; copy it; modify.
- Onboard an agent (the `sa-assistant` skill in `.claude/skills/`) — these are the patterns it pattern-matches against in `/build-poc`.
- Sanity-check a refactor of the modules — if these compositions still apply cleanly, the change is probably non-breaking.

## Archetypes

| Demo | What it shows | Modules pulled | Helm charts pulled |
|---|---|---|---|
| [`single-cluster`](./single-cluster) | One k8s cluster + Traefik Hub + whoami. The "hello world" — proves the wiring. | `terraform/compute/<cloud>`, `terraform/traefik/k8s`, `terraform/apps/whoami/k8s` | — |
| [`unified-ingress`](./unified-ingress) | Multicluster transit + app-workload pattern — the dominant real-world shape. | `terraform/compute/<cloud>` (×N), `terraform/traefik/k8s` (parent + children), `terraform/observability/opentelemetry/k8s`, `terraform/apps/whoami/k8s` | `dns-traefiker` |
| [`ai-gateway`](./ai-gateway) | AI gateway + one model backend + Keycloak. Captures the AI workflow without RunPod cost. | `terraform/compute/<cloud>`, `terraform/traefik/k8s`, `terraform/security/keycloak/k8s`, `terraform/ai/ollama/k8s` | `ai-gateway`, `presidio`, `embeddings` |
| [`oidc-portal`](./oidc-portal) | Traefik Hub API Portal + Cognito (swap for EntraID or Keycloak). | `terraform/compute/aws/eks`, `terraform/traefik/k8s`, `terraform/security/cognito`, `terraform/apps/whoami/k8s` | — |
| [`nutanix-on-prem`](./nutanix-on-prem) | Full Nutanix infra stack — subnet → storage → VPC → FIP → NKP. | `terraform/compute/nutanix/*`, `terraform/traefik/k8s` | — |

## Conventions

Every archetype ships:

- `main.tf` — the module composition (this is the file an agent should pattern-match against)
- `variables.tf` — inputs the demo expects
- `terraform.tfvars.example` — placeholder values. **Never commit real values.**
- `outputs.tf` — the canonical Traefik IP + dashboard URL + any module pass-throughs
- `README.md` — what the demo proves, install steps, how to extend

## What these are NOT

- Production-grade. They use the smallest cluster size, in-cluster databases, and demo credentials.
- A complete tutorial. They expect the reader to know Terraform + Helm basics.
- Tied to the real demos. If a real demo diverges, that demo is the source of truth — these are just the canonical shapes.

## Module sources

All sources use the `terraform/<section>/<path>` layout introduced in v4.0.0. If you're updating an existing v3.x demo, hand-edit the `module "..." { source = ... }` lines to insert `terraform/` after `terraform-demo-modules.git//` and bump `?ref=v3.X.Y` to a v4.x.y tag.
