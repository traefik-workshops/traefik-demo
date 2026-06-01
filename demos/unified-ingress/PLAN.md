# `unified-ingress` — build plan & audit trail

> Multi-cloud Traefik Hub mesh: one **EKS hub** is the unified ingress, fronting workloads on
> **EC2, ECS, and AKS** over Hub multicluster uplinks **secured with SPIFFE mTLS**. Status:
> **All phases (0–8) built and validating offline; live apply + scenarios pending creds.** This
> file is the build's source of truth; delete it before the demo ships (or keep as design notes).

## Decisions (locked with the user)

| Topic | Decision |
|---|---|
| Shape | **One** demo (not a suite). Name: `unified-ingress` (the old k3d demo was renamed `k3d-unified-ingress`). |
| Hub / spokes | **EKS = hub** (multicluster parent). **Spokes = EC2, ECS, AKS** (children over Hub uplinks). |
| AI/MCP gateway | On the **AKS** spoke (guardrails + token rate-limit + MCP), traces → Langfuse on the EKS hub. |
| APIM + portal | On the **EKS hub**, gated by **Keycloak** (JWT + portal OIDC), aks-demo pattern. |
| Observability | On the **EKS hub**: OTel collector + Grafana stack + Langfuse. Every spoke's OTLP → hub collector. |
| nginx migration | NGINX Ingress provider on EKS — **wired + tested** (it's first-class: `provider.kubernetesingressnginx`). |
| WAF / mirroring / failover | **Wired + tested** (Coraza middleware; mirroring + cross-cluster failover TraefikServices). |
| SPIFFE/SPIRE | Secures the **multicluster uplinks** (not a workload mesh). **Per-cluster trust domains + federation.** Scope: **all four, phased** — prove EKS↔AKS first, then EC2 + ECS. |
| Tests | **curl** everywhere. Cloud → `terraform validate`-only in CI; scenarios run by hand. |
| Narrated-only (no module/test) | FIPS, private plugins, Gateway API, plugin catalog. |

## Phase 0 verification evidence (Traefik v3.7 + Hub v3.20.2 reference)

- **SPIFFE mTLS on the uplink is supported.** `ServersTransport.spiffe = { ids:[], trustDomain }`
  (`.reference/schemas/traefik.io/serverstransport_v1alpha1.json:173`). The multicluster
  `children.<name>.serversTransport` is this exact type (today `insecureSkipVerify`) → replace with
  `spiffe.ids`. The shared module passes `children` through as `any` (`terraform/traefik/shared/helm_values.tf:36`) → **no traefik-module change**.
- **`static.spiffe` / `SpiffeClientConfig`** (workloadAPIAddress) → each Traefik reads its SPIRE agent socket.
- **Child `Uplink` CRD** has `entryPoints` + active/passive health checks (`.reference/schemas/hub.traefik.io/uplink_v1alpha1.json`).
- **NGINX provider is first-class**: `provider.kubernetesingressnginx` + `annotations.ingress-nginx`.
- **`concept.failover`** exists (cross-cluster failover service kind).
- Live proof of the cross-cloud uplink happens in the **Phase 2** EKS↔AKS spike.

## Component placement

| Compute | Runs |
|---|---|
| **EKS hub** (parent) | Traefik Hub (unified ingress, multicluster parent) · nginx-provider migration · WAF (Coraza) · mirroring+failover · APIM + Portal · Keycloak · OTel + Grafana + Langfuse · **SPIRE server** (trust domain `eks`) · whoami |
| **AKS** (child) | Traefik Hub child · **AI gateway** (Presidio + Redis + guards) · **MCP gateway** · SPIRE server (`aks`, federated) · whoami |
| **EC2** (child) | Traefik Hub (VM, EIP) · SPIRE agent (`aws_iid`) · whoami |
| **ECS** (child) | Traefik Hub (Fargate) · SPIRE agent · whoami |

## Module list (relative sources)

- **Net-new module to scaffold:** `terraform/security/spire/k8s` — wraps `spire-crds` + `spire`
  (`https://spiffe.github.io/helm-charts-hardened/`, chart `v1.14.6`: spire-server, spire-agent,
  spiffe-csi-driver, spire-controller-manager). Inputs: `namespace`, `trust_domain`, `cluster_name`,
  `federation` (bundle endpoints + ClusterFederatedTrustDomain). Outputs: `trust_domain`,
  `bundle_endpoint`, `bundle`.
- **EKS:** `compute/aws/vpc`, `compute/aws/eks` (2× `m5.2xlarge`), `traefik/k8s` (parent),
  `security/spire/k8s`, `security/keycloak/k8s`, `observability/{opentelemetry,grafana-stack,langfuse}/k8s`,
  `tools/nginx/k8s`, `apps/whoami/k8s`.
- **AKS:** `compute/azure/aks` (2× `Standard_D4s_v5`), `traefik/k8s` (child), `security/spire/k8s`,
  `ai/presidio/k8s`, `tools/redis/k8s`, `tools/mcp-inspector/k8s`, `apps/whoami/k8s`.
- **EC2/ECS:** `traefik/ec2` (`t3.medium`, `create_eip`) + `apps/whoami/ec2` · `traefik/ecs` (Fargate) +
  `apps/whoami/ecs`. SPIRE agent injected via cloud-init (`extra_files`) / ECS sidecar.
- **Inline CRDs/config:** AI-gw middleware chain, APIM CRDs, Coraza WAF middleware, mirroring/failover
  `TraefikService`s, parent `<spoke>@multicluster` routes with `serversTransport.spiffe`.

## SPIFFE/SPIRE wiring (per-cluster trust domains + federation)

- Trust domains: `eks.unified-ingress`, `aks.unified-ingress`, `ec2.unified-ingress`, `ecs.unified-ingress`.
- Each Traefik: `--spiffe.workloadAPIAddress=unix:///spiffe-workload-api/spire-agent.sock` (csi.spiffe.io volume).
- Child advertises its uplink entrypoint (presents its SVID); parent verifies via
  `children.<spoke>.serversTransport.spiffe.ids = ["spiffe://<spoke-td>/ns/.../traefik"]`.
- SPIRE federation: each cluster's spire-server exposes a bundle endpoint; `ClusterFederatedTrustDomain`
  CRs cross-trust. EC2/ECS use the `aws_iid` node attestor.

## File layout (`demos/unified-ingress/`)

`versions.tf` · `providers.tf` (aliased per-cluster providers) · `main.tf` (VPC+EKS+hub Traefik) ·
`spokes-aks.tf` · `spokes-ec2.tf` · `spokes-ecs.tf` · `spire.tf` · `routes.tf` (`<spoke>@multicluster`
+ spiffe serversTransport) · `nginx-migration.tf` · `waf.tf` · `mirroring-failover.tf` · `apim.tf` ·
`ai-mcp-gateway.tf` · `observability.tf` · `variables.tf` · `outputs.tf` · `terraform.tfvars.example` ·
`Makefile` · `scenarios.sh` · `README.md`.

## Test scenarios (curl → README expected table)

1. EKS hub baseline (`whoami` via LB) → 200
2. nginx-provider migration (native nginx Ingress served by Traefik) → 200 + Traefik header
3. EC2 spoke via `ec2@multicluster` → 200 (EC2 hostname)
4. ECS spoke via `ecs@multicluster` → 200
5. AKS spoke via `aks@multicluster` → 200
6. **SPIFFE-mTLS uplink** — spoke route works AND `serversTransport.spiffe` applied (config assert)
7. WAF (Coraza) — SQLi/XSS → 403; benign → 200
8. mirroring — primary → 200 (+ best-effort shadow receipt)
9. cross-cluster failover — failover route → 200 (scripted "stop primary → still 200")
10. APIM — no JWT → 401; Keycloak JWT → 200
11. portal → 200/302
12. AI guardrails (on AKS) — PII/email blocked; clean passes
13. AI token rate-limit → 429
14. MCP gateway / mcp-inspector → 200
15. observability — Grafana & Langfuse → 200/302

## CI + registration

- Add to the `demos-ci.yml` **validate** glob (auto: it iterates `demos/*/`). **Not** in the k3d deploy matrix.
- Add a row to `demos/README.md`.

## Implementation phasing

0. **Verify + scaffold** — ✅ DONE. Linchpin verified; `spire` module scaffolded; demo skeleton + this PLAN.
1. **EKS hub baseline + nginx migration** — ✅ DONE (validates offline).
2. **AKS spoke + SPIFFE uplink** — ✅ DONE (validates offline; live EKS↔AKS SPIFFE proof pending a real apply).
3. **AI/MCP gateway on AKS** — ✅ DONE (validates offline).
4. **EC2 + ECS spokes** — ✅ DONE (uplinks wired; SPIFFE-on-VM/ECS is the documented extension — insecureSkipVerify for now).
5. **APIM + portal + Keycloak** — ✅ DONE (validates offline).
6. **Observability (OTel + Grafana + Langfuse; all spokes' OTLP → hub)** — ✅ DONE.
7. **WAF + mirroring + failover** — ✅ DONE (coraza plugin moduleName/version best-effort).
8. **scenarios.sh + README + demos/README + CI (validate auto-globs demos/*/)** — ✅ DONE.
9. **`make fmt && make validate`** — ✅ offline gate green. End-to-end apply + scenarios are **by-hand** on real AWS+Azure (not run here).

## Top risks / open items

- SPIRE-on-EC2/ECS + cross-cloud federation (Phase 4) — has a fallback (native uplink TLS).
- Single apply across 2 clouds / 4 clusters — needs `depends_on` / two-phase (`-target` spokes → routes).
- Real domain via `dns_traefiker` (Cloudflare token) for portal OIDC + Keycloak issuer + per-host certs.
- Cost ≈ $1.5–2/hr (EKS + AKS + EC2 + Fargate + LBs); run-by-hand, destroy after.
- Asserting "uplink is SPIFFE-mTLS" in pure curl is indirect — assert route + applied config, documented honestly.
