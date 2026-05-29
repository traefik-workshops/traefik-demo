# demos/aks-demo

Traefik Hub **API Management** on **AKS**, wired end to end:

- **Keycloak** is the IdP. It mints JWTs and is exposed at `keycloak.<domain>`.
- The **whoami API** is a managed API behind a **default JWT `APIAuth`** — no
  token is rejected, a Keycloak-issued token is accepted.
- A **developer API Portal** (`portal.<domain>`) signs users in with **Keycloak
  SSO** (OIDC) and lists the whoami API in its catalog for the `developers` group.
- **Observability over OpenTelemetry**: Traefik metrics → Prometheus and access
  logs → Loki (the **Grafana stack**, `grafana.<domain>`), and Traefik traces →
  **Langfuse** (`langfuse.<domain>`).
- **dns-traefiker** registers `*.<domain>` at the Traefik LoadBalancer IP and
  feeds its Cloudflare token to Traefik's `cf` Let's Encrypt resolver, so every
  hostname has real DNS + a real cert — which is what makes the Keycloak issuer /
  JWKS and the portal OIDC redirect reachable from both the browser and Hub.

## What it proves

- Traefik Hub API Management + Portal install on AKS.
- A Keycloak-issued JWT gates a managed API (default `APIAuth`), and the same
  realm backs the Portal's OIDC SSO.
- Traefik telemetry fans out over a single OTel collector to the Grafana stack
  (metrics + logs) and Langfuse (traces).

## Prerequisites

- `terraform`, `kubectl`, and the Azure CLI (`az login` — the `azurerm` provider
  uses your ambient credentials).
- A **Traefik Hub token** (offline JWT). DNS + TLS need no input here — the
  in-cluster dns-traefiker controller supplies the Cloudflare token (from its
  `domain-secret`) for both DNS registration and the Let's Encrypt `cf` resolver.

## Run

```bash
cp terraform.tfvars.example terraform.tfvars   # fill in tokens + domain
make up                                          # ~10 min (AKS + Hub + the stack)
make scenarios                                   # curl the gates (reads tf outputs)
make down
```

`make scenarios` reads the domain and a ready-made `developer` JWT from the
terraform outputs. To curl by hand:

```bash
TOKEN=$(terraform output -raw developer_jwt)
curl https://whoami.<domain>/                         # 401 — no token
curl -H "Authorization: Bearer $TOKEN" https://whoami.<domain>/   # 200
```

## Expected results

| Route | Without auth | With Keycloak JWT |
|---|---|---|
| `whoami.<domain>` | **401/403** (default JWT `APIAuth`) | **200** |
| `portal.<domain>` | **200 / 302** (page or OIDC redirect to Keycloak) | signed-in portal |
| `keycloak.<domain>/realms/traefik/.well-known/openid-configuration` | **200** | — |
| `grafana.<domain>` | **200 / 302** | — |
| `langfuse.<domain>` | **200 / 302** | — |
| `dashboard.<domain>` | Traefik Hub dashboard | — |

## Sign in to the Portal

Open `portal.<domain>`, click sign-in, and authenticate against Keycloak as
**`developer` / `topsecretpassword`**. The `developer` user is in the
`developers` group (carried in the JWT `group` claim), which the
`whoami-access` `APICatalogItem` publishes the whoami API to.

## Notes

- **Portal SSO is a browser flow** — `make scenarios` only asserts the portal
  endpoint responds; the full OIDC login is interactive (same as `oidc-portal`).
- **Langfuse UI login**: the module is deployed with `ingress = false` (its
  built-in `kubernetes_manifest` ingress can't plan against a CRD that doesn't
  exist yet on a fresh cluster), so its `NEXTAUTH_URL` is `localhost`. Trace
  **ingest** over OTel works regardless. To log into the UI, port-forward:
  `KUBECONFIG=.kubeconfig kubectl -n traefik-observability port-forward svc/langfuse-web 3000:3000` → http://localhost:3000
  (login `admin@traefik.io` / `topsecretpassword`). The `langfuse.<domain>`
  route is still created for browsing.
- **Heavy stack, sized for ~60% CPU.** ~20 pods (Langfuse alone brings
  ClickHouse + Postgres + Redis + MinIO) request ~5 vCPU; with kube-system that's
  ~5.7 vCPU. Default is **3× `Standard_D4s_v5`** (12 vCPU / 48 GB, ~11.6 vCPU
  allocatable) → ~50% requested, so CPU peaks around 60% with headroom for boot
  spikes (Keycloak realm import, Langfuse migrations, ClickHouse init). Use a
  **non-burstable D-series** SKU — burstable B-series throttles below baseline
  under sustained load. Tune via `cluster_node_type` / `cluster_node_count`.

## Secrets

Real inputs live in the gitignored `terraform.tfvars`; only
`terraform.tfvars.example` (placeholders) is committed. The demo is
white-labeled — supply your own domain and Hub token.

## Sourced from

`demos/oidc-portal` (cloud + API Portal), with EKS+Cognito swapped for
AKS+Keycloak and the observability stack + dns-traefiker added. The Hub APIM
CRDs are the `helm/airlines` shapes trimmed to a single API.
