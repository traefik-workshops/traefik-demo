# Demo / PoC build spec — shared by `/create-demo` and `/create-poc`

Both `/create-demo` and `/create-poc` build the **same kind of artifact**: a runnable
Traefik Hub composition with automated tests. They differ only in *where it lives* and
*how the library is referenced*:

| | `/create-demo` | `/create-poc` |
|---|---|---|
| Output location | `demos/<name>/` (in this repo) | a **separate git repo** |
| Module sources | **relative** (`../../terraform/...`) | **pinned** (`git::...?ref=<tag>`, `helm --version <tag>`) |
| Audience | the team / CI | a prospect (hand-off artifact) |
| Extra hand-holding | no — fits the existing `demos/` set | yes — a `GETTING-STARTED.md` walkthrough |

Everything else on this page — the questionnaire, the module mapping, the layout, the
test convention — is **identical** for both. Read this once; each command layers its
location/pinning/hand-holding rules on top.

---

## Golden rule: copy the nearest reference demo, don't generate from scratch

The four runnable demos under [`demos/`](../../../demos/) exist precisely so this skill
has correct, working shapes to pattern-match against (see
[`demos/AGENTS.md`](../../../demos/AGENTS.md)). The tricky bits — provider blocks fed from
cluster outputs, the local-exec kubeconfig the traefik module needs for CRD install, the
multicluster uplink wiring, k3d host-port collisions — are already solved there. **Start
from the closest reference demo and adapt it.** Do not hand-write a composition from a
blank file; you will get the provider/kubeconfig/uplink wiring subtly wrong.

| Build includes… | Start from | Why |
|---|---|---|
| single cluster, baseline | [`demos/single-cluster`](../../../demos/single-cluster) | minimal cluster + Hub + whoami |
| **multi-cluster** | [`demos/unified-ingress`](../../../demos/unified-ingress) | parent "transit" + child "app-workload", uplink + multicluster provider wiring |
| **AI gateway** | [`demos/ai-gateway-openai`](../../../demos/ai-gateway-openai) | `enable_ai_gateway`, Presidio + Redis content-guard chain, OpenAI-compatible backend |
| **API management + portal** | [`demos/oidc-portal`](../../../demos/oidc-portal) | `enable_api_management` (the portal lives here) + a cloud compute shape |

Compose features by merging the relevant reference shapes (e.g. multi-cluster + AI gateway
= unified-ingress wiring with `enable_ai_gateway = true` on the relevant traefik module).

Only reference modules/charts that exist in [`catalog.json`](../../../catalog.json). Never
invent a path. If the catalog looks stale, run `make catalog`.

---

## The questionnaire

Gather these before rendering anything. Use the `AskUserQuestion` tool. Apply the
**defaults** when the user doesn't care — a demo must be runnable from the minimum input.

1. **Name** — kebab-case (`acme-mcp`, `multicluster-grafana`). Becomes the demo folder
   name or the PoC repo name.

2. **Infra (compute)** — *defaults to `k3d`* (`terraform/compute/suse/k3d`, free + local).
   Any `terraform/compute/<cloud>/<name>` in the catalog is selectable: `aws/eks`,
   `azure/aks`, `gcp/gke`, `oracle/oke`, `digitalocean/doks`, `akamai/lke`, `nutanix/nkp`,
   `imported/k8s` (bring-your-own kubeconfig). A cloud choice pulls in its prerequisites
   (e.g. `aws/eks` needs `aws/vpc` — see `demos/oidc-portal`).

3. **Topology** — *single-cluster* (default) or *multi-cluster*.
   - **Multi-cluster → ask for the other compute.** The second ("app-workload"/child)
     cluster's infra defaults to the **same** platform as the first, but the user may pick
     a different one (e.g. parent on EKS, child on k3d). Wire it per `unified-ingress`:
     parent runs the multicluster provider, child exposes a Hub uplink entrypoint, parent
     route forwards to `<child>@multicluster`.

4. **Observability** — enabled? (*default: off*). If **on**, pick a backend:
   - *defaults to **grafana*** → `terraform/observability/grafana-stack/k8s`
     (Grafana + Prometheus). For traces/logs, pair with
     `terraform/observability/opentelemetry/k8s` as the OTLP sink and point its
     Prometheus/Loki/Tempo pipelines at the stack (the `unified-ingress` demo shows the
     collector pattern).
   - *any other otel-supported backend* → `terraform/observability/opentelemetry/k8s`
     configured with that backend's pipeline. The collector module supports
     **Prometheus, Loki, Tempo, New Relic, Dash0, Honeycomb, LangSmith, Langfuse** — read
     its `variables.tf` for the exact per-backend knobs (endpoint + API key). Backends
     other than grafana usually need no in-cluster UI.
   - Whichever backend: turn on telemetry at the gateway —
     `enable_otlp_metrics`, `enable_otlp_traces`, `enable_otlp_access_logs = true` and
     `otlp_address = "http://<collector-svc>.<ns>.svc.cluster.local:4318"` on the traefik
     module(s).

5. **API management + portal** — enabled? (*default: off*). →
   `enable_api_management = true` on the traefik module (the **API Portal lives here** —
   see `demos/oidc-portal`). For a populated portal with sample APIs, optionally add the
   `helm/airlines` umbrella chart (Scalar mock APIs + Hub API Management). When the portal
   is on, default the test harness to **hoppscotch** (see Tests below).

6. **AI gateway** — enabled? (*default: off*). → `enable_ai_gateway = true`. For the full
   content-guard experience, add `terraform/ai/presidio/k8s` (PII engine) + a Redis
   deployment for the token rate-limit, and an OpenAI-compatible upstream — copy the
   `ai-gateway-openai` shape wholesale.

7. **MCP gateway** — enabled? (*default: off*). → `enable_mcp_gateway = true` on the
   traefik module. Optionally add `terraform/tools/mcp-inspector/k8s` as an in-cluster test
   client.

A **sample workload is always included** (`terraform/apps/whoami/k8s`) so the test harness
always has at least one route to assert against, unless the build is AI/MCP-only (then the
gateway endpoint is the target).

---

## Config → module / chart mapping

| Choice | Pulls in | traefik/k8s flags |
|---|---|---|
| infra = k3d *(default)* | `compute/suse/k3d` | — |
| infra = `<cloud>` | `compute/<cloud>/...` (+ deps, e.g. `aws/vpc`) | — |
| *(always)* | `traefik/shared` + `traefik/k8s` | `enable_api_gateway = true`, `enable_offline_mode = true` |
| multi-cluster | second compute module + parent/child `traefik/k8s` + uplink | `multicluster_provider`, `custom_ports`/`custom_arguments` (child) |
| observability = grafana *(default when on)* | `observability/grafana-stack/k8s` (+ `opentelemetry/k8s` for traces/logs) | `enable_otlp_metrics/traces/access_logs`, `otlp_address` |
| observability = other otel backend | `observability/opentelemetry/k8s` (backend pipeline) | same `enable_otlp_*` + `otlp_address` |
| API management + portal | *(traefik flag)* + optional `helm/airlines` | `enable_api_management = true` |
| AI gateway | *(traefik flag)* + optional `ai/presidio/k8s` + Redis | `enable_ai_gateway = true` |
| MCP gateway | *(traefik flag)* + optional `tools/mcp-inspector/k8s` | `enable_mcp_gateway = true` |
| *(always, unless gateway-only)* | `apps/whoami/k8s` | — |

Confirm the resolved module/chart list with the user before writing files.

---

## Canonical layout

Follow the runnable-demo layout from [`demos/AGENTS.md`](../../../demos/AGENTS.md) exactly:

```
<output-root>/
├── versions.tf              # required_providers (incl. k3d for local builds)
├── main.tf                  # the composition
├── variables.tf             # every var has type + description
├── outputs.tf               # dashboard / route URLs + module pass-throughs
├── terraform.tfvars.example # placeholders only — NEVER a real value
├── Makefile                 # up / down / scenarios / fmt / validate
├── scenarios.sh             # automated tests (curl and/or hoppscotch)
└── README.md                # what it proves, prereqs, run steps, secrets note
```

`/create-poc` adds a `GETTING-STARTED.md` walkthrough on top of this.

Variable + output + provider conventions are the repo-wide ones in
[`/AGENTS.md`](../../../AGENTS.md): snake_case, `enable_<thing>` toggles, every var typed +
described, secrets `sensitive = true`, providers pinned with `~>`.

---

## Automated tests (required)

Every build ships a `Makefile` (`up` / `scenarios` / `down` / `fmt` / `validate`) and a
`scenarios.sh` that **deploys nothing itself** — `make up` deploys, `make scenarios` asserts
against the running stack. Two harness styles (the user requirement: *curl OR hoppscotch*):

- **curl** *(default)* — copy the `pass`/`fail`/`wait_200` helper structure from
  [`demos/single-cluster/scenarios.sh`](../../../demos/single-cluster/scenarios.sh) (simple
  reachability) or [`demos/ai-gateway-openai/scenarios.sh`](../../../demos/ai-gateway-openai/scenarios.sh)
  (POST + body assertions for guard rejections). Resolve hosts to `127.0.0.1` for k3d
  (`--resolve <host>:443:127.0.0.1`, `-k` for self-signed), retry briefly for route
  propagation, exit non-zero on any failure.
- **hoppscotch** *(default when API management + portal is on)* — deploy the
  `helm/hoppscotch` chart with the demo's API collections (it serves multi-collection
  via nginx), and drive the collections with the Hoppscotch CLI (`hopp test`) in
  `scenarios.sh`. Use this when the value being proven is a multi-request API flow through
  the portal rather than a single route check.

Each scenario must map to a row in an **expected table** in the demo README (route →
expected status / behavior), so a reader knows what "pass" means.

After rendering, run the static gate (`terraform fmt -check` + `terraform validate` — for a
demo, `make validate`; for a PoC, the same offline against the pinned sources after `init`).
For k3d builds, offer to `make up && make scenarios && make down` to prove it end-to-end —
this needs a `TRAEFIK_HUB_TOKEN` (offline JWT). Cloud builds are `validate`-only without
credentials; say so rather than claiming the scenarios passed.
