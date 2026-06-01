# demos/unified-ingress

A multi-cloud **Traefik Hub mesh**: one **EKS hub** is the unified ingress, fronting
workloads that live on **EC2** (VMs), **ECS** (containers), and **AKS** (Azure k8s) — joined
over Hub multicluster uplinks **secured with SPIFFE mTLS** (SPIRE, per-cluster trust domains,
federated). On top of the mesh it layers an NGINX→Traefik migration, a WAF, request mirroring
+ cross-cluster failover, API Management + a developer portal, an AI + MCP gateway, and full
observability — all under one ingress.

```
              client ──https──▶  EKS HUB (unified ingress, multicluster parent)
                                 ├─ nginx-provider migration · WAF (Coraza)
                                 ├─ mirroring + cross-cluster failover
                                 ├─ APIM + Portal (Keycloak JWT/OIDC)
                                 └─ Observability: OTel → Grafana + Langfuse
                ┌──────────────── SPIFFE-mTLS uplinks ────────────────┐
              AKS child            EC2 child            ECS child
              AI + MCP gw          whoami (VM)          whoami (Fargate)
              whoami               + SPIRE agent        + SPIRE agent
              every spoke ── OTLP ──▶ hub collector (otel.<domain>)
```

> **Cloud demo.** CI only `terraform validate`s it (relative module sources resolve offline);
> `apply` + `scenarios` are run by hand against AWS + Azure. The free, single-host cousin is
> [`k3d-unified-ingress`](../k3d-unified-ingress). The full architecture, decisions, and phase
> notes live in [`PLAN.md`](./PLAN.md).

## What it proves

| Use case | What |
|---|---|
| **UC1** NGINX→Traefik | EKS hub baseline + the `kubernetesIngressNGINX` provider serving a native nginx Ingress unchanged |
| **UC2** VM→container coexistence | EC2 + ECS + AKS workloads fronted by one EKS ingress over Hub uplinks; **SPIFFE mTLS** on the uplinks; WAF (Coraza); mirroring + cross-cluster failover; APIM (auth + subscriptions) + developer Portal (Keycloak) |
| **UC3** AI + MCP gateway | AI gateway on AKS — content guards (regex + Presidio) + Redis token rate-limit — fronted by the hub; MCP inspector; traces → Langfuse on the hub |
| **UC5** Observability | OTel collector on the hub → Grafana (metrics + logs) + Langfuse (traces); every spoke ships OTLP to the hub |

## Prerequisites

- `terraform`, `aws` (configured), `az` (logged in), `kubectl`
- A **Traefik Hub** token (offline JWT) — <https://hub.traefik.io>
- A **domain** in a **Cloudflare** zone + a Cloudflare API token (for `dns-traefiker` DNS +
  Let's Encrypt). The token goes in the `dns-traefiker` `domain-secret`, not a Terraform input.

## Run

```bash
cp terraform.tfvars.example terraform.tfvars   # fill in domain + hub token
make up                                         # stand up the hub + spokes + mesh
make scenarios                                  # curl every route (table below)
make down                                        # tear everything down
```

`make validate` runs the offline static gate (no cloud, no secrets).

> **Two-phase apply.** The hub's multicluster children dial each spoke's public uplink, so the
> spokes (and their LoadBalancer IPs) must exist first. If a single `make up` races, apply the
> spokes then the hub: `terraform apply -target=module.aks_traefik -target=module.ec2_traefik
> -target=module.ecs_traefik` then a plain `terraform apply`.

## Expected results

| # | Scenario | Route | Expected |
|---|---|---|---|
| 1 | Hub whoami (JWT gate) | `whoami.<domain>/` | `401` without JWT · `200` with the Keycloak JWT |
| 2 | NGINX→Traefik migration | `legacy.<domain>/` | `200` (native nginx Ingress via Traefik) |
| 3 | AKS spoke (SPIFFE uplink) | `aks.<domain>/` | `200` |
| 4 | EC2 spoke | `ec2.<domain>/` | `200` |
| 5 | ECS spoke | `ecs.<domain>/` | `200` |
| 6 | WAF (Coraza) | `waf.<domain>/?id=1' OR '1'='1` | `403` · benign `200` |
| 7 | Mirroring | `mirror.<domain>/` | `200` (shadow copy out-of-band) |
| 8 | Cross-cluster failover | `failover.<domain>/` | `200` (AKS primary, hub fallback) |
| 9 | API Portal | `portal.<domain>/` | `200/302` (OIDC) |
| 10 | Keycloak OIDC | `keycloak.<domain>/realms/traefik/.well-known/openid-configuration` | `200` |
| 11 | AI guardrails | `POST ai.<domain>/v1/chat/completions` (PII/email) | "Request blocked" |
| 12 | MCP inspector | `mcp.<domain>/` | `200/302` |
| 13 | Grafana | `grafana.<domain>/` | `200/302` |
| 14 | Langfuse | `langfuse.<domain>/` | `200/302` |

## Caveats (verified on a live apply, not offline)

- **SPIFFE on the AKS uplink** is fully wired; **EC2/ECS uplinks** use `insecureSkipVerify` —
  SPIFFE-on-VM/Fargate (a SPIRE agent with the `aws_iid` attestor) is the documented extension.
- **Cross-cloud SPIRE federation** (bundle endpoints, `https_web` bootstrap) and the **VM/ECS
  Hub uplink advertising** are best-effort; fallback for EC2/ECS is an ExternalName from the hub.
- **The Coraza plugin** `moduleName`/`version` (in `main.tf`) is best-effort — confirm it against
  the Traefik plugin catalog.
- Forcing a **failover** / confirming a **mirror receipt** isn't a pure-curl check — scenarios
  assert the happy path; the manual steps are noted inline.

## Secrets

Never commit real values. Real inputs go in `terraform.tfvars` (gitignored); only
`terraform.tfvars.example` (placeholders) is committed.
