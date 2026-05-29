# Create Demo

Scaffold a new runnable demo under [`demos/`](../../demos/) — a white-labeled, generic
composition of this repo's library with automated tests. The demo lives **inside** this
repo, references modules with **relative** paths, and is wired to run in CI like its
siblings.

Use this when someone says *"create a demo for X"*, *"add a demo that shows Y"*, *"scaffold
a generic demo"*. For a standalone, prospect-facing artifact in its **own git repo** with
pinned versions and a hand-holding walkthrough, use [`/create-poc`](./create-poc.md)
instead.

> Read [`sa-assistant/demo-spec.md`](../skills/sa-assistant/demo-spec.md) first — it defines
> the questionnaire, the config→module mapping, the layout, and the test convention shared
> with `/create-poc`. This command only adds the **in-repo, relative-source** rules.

## Invocation

```
/create-demo
/create-demo <name>            # pre-seed the demo name
```

## Step 1 — Gather the config

Run the questionnaire from [`demo-spec.md`](../skills/sa-assistant/demo-spec.md#the-questionnaire):
name, infra (default k3d), topology (single / multi — if multi, the other compute),
observability (default off; if on, default grafana, else any otel backend), API management
+ portal, AI gateway, MCP gateway.

Then resolve the config → module/chart list via the
[mapping table](../skills/sa-assistant/demo-spec.md#config--module--chart-mapping) and read
`catalog.json` to confirm every path exists and to pull each module's required inputs. For a
cloud/managed cluster, also compute the node pool (SKU + count) from the resolved stack per
[Right-sizing a node pool](../skills/sa-assistant/demo-spec.md#right-sizing-a-node-pool).
**Show the resolved module list and the node pool (SKU + count + ~%-requested), and ask the
user to confirm before writing files.**

## Step 2 — Pick the seed demo and copy it

Per the [golden rule](../skills/sa-assistant/demo-spec.md#golden-rule-copy-the-nearest-reference-demo-dont-generate-from-scratch),
copy the nearest existing demo as the starting point rather than writing Terraform from
scratch:

```bash
cp -r demos/<seed> demos/<name>
rm -rf demos/<name>/.terraform demos/<name>/.terraform.lock.hcl \
       demos/<name>/terraform.tfvars demos/<name>/.kubeconfig demos/<name>/.*.kubeconfig
```

Seed selection (combine shapes for multi-feature demos):

| Build | Seed |
|---|---|
| single-cluster baseline | `single-cluster` |
| multi-cluster | `unified-ingress` |
| AI gateway | `ai-gateway-openai` |
| API management + portal (and/or cloud infra) | `oidc-portal` |

## Step 3 — Adapt the composition

Edit the copied `main.tf` / `variables.tf` / `outputs.tf` to match the resolved config:

- **Module sources are RELATIVE** — `source = "../../terraform/<section>/<path>"`. Never
  `git::...?ref=<tag>`, never an absolute path. This is the demo convention (the demo
  tracks the library in this checkout so `terraform validate` runs offline). See
  [`demos/AGENTS.md`](../../demos/AGENTS.md#module-sources-relative-not-pinned). Pinning is
  `/create-poc`'s job, not this one.
- **Swap the compute module** to the chosen infra. For k3d keep the `k3d` provider in
  `versions.tf`; for a cloud, drop `k3d` and follow `oidc-portal`'s provider wiring
  (token-based, no local-exec kubeconfig). Don't add a Traefik `ports`/`exposedPort`
  override for a cloud cluster — `traefik/k8s` already binds the entrypoints on unprivileged
  container ports and publishes 80/443 at the Service, so delete any such block you inherit
  from a seed (see
  [demo-spec → Traefik on a cloud cluster](../skills/sa-assistant/demo-spec.md#traefik-on-a-cloud-cluster-ports-are-already-handled)).
  **Right-size the node pool** for the resolved
  stack instead of inheriting the module's single-small-node default — a non-burstable SKU
  + count so aggregate pod requests land ~50–60% of allocatable (the math + a worked example
  are in
  [demo-spec → Right-sizing a node pool](../skills/sa-assistant/demo-spec.md#right-sizing-a-node-pool)),
  confirmed with the user in Step 1.
- **Toggle the traefik flags** per the mapping table (`enable_api_management`,
  `enable_ai_gateway`, `enable_mcp_gateway`, the `enable_otlp_*` + `otlp_address` set).
- **Multi-cluster:** keep the parent/child split, the per-cluster providers, the uplink
  entrypoint + `multicluster_provider`, and the parent `<child>@multicluster` route from
  `unified-ingress`. If the second compute differs from the first, swap only that module.
- **Observability:** add the chosen `observability/*` module and point the gateway's
  `otlp_address` at its collector service.
- **De-brand.** No client names, real domains, tokens, or sample data — `*.localhost` for
  k3d, placeholders in `terraform.tfvars.example` only.

## Step 4 — Write the test harness

Author `scenarios.sh` + `Makefile` per
[demo-spec Tests](../skills/sa-assistant/demo-spec.md#automated-tests-required):

- Default to **curl** assertions (copy the helper structure from the seed's `scenarios.sh`).
- When API management + portal is on, default to **hoppscotch** — deploy `helm/hoppscotch`
  with the demo's collections and drive them with `hopp test`.
- The `Makefile` exposes `up` / `scenarios` / `down` / `fmt` / `validate` (copy from the
  seed; adjust the help text and `DOMAIN`).
- Every scenario maps to a row in the README's expected table.

## Step 5 — README + tfvars

- `terraform.tfvars.example` — placeholders only (`traefik_hub_token = "REPLACE_ME"`, the
  chosen `domain`/`cluster_name`). Never a real value.
- `README.md` — what it proves, prerequisites, the `cp tfvars → make up → make scenarios →
  make down` run steps, the expected-results table, and a secrets note. Follow the shape of
  the seed's README.

## Step 6 — Wire CI + register the demo

- **k3d demos run in CI.** Add the new demo to the matrix in
  [`.github/workflows/demos-ci.yml`](../../.github/workflows/demos-ci.yml) (deploy +
  scenarios, gated on `TRAEFIK_HUB_TOKEN`). A cloud demo is `terraform validate`-only there
  — match how `oidc-portal` is handled.
- Add a row to the demos table in [`demos/README.md`](../../demos/README.md).

## Step 7 — Validate

```bash
cd demos/<name>
make fmt
make validate          # offline — relative sources resolve locally
```

For a k3d demo, offer to prove it end-to-end (needs a Hub token in `terraform.tfvars`):

```bash
make up && make scenarios && make down
```

Report results honestly: if you only ran `validate` (no token / cloud creds), say the
scenarios were **not** executed — don't claim a green run you didn't do.

## Rules

- **Relative sources only.** Pinned `?ref=` is the PoC convention, not the demo convention.
- **No real values committed** — `terraform.tfvars.example` is placeholders; real inputs go
  in the gitignored `terraform.tfvars`.
- **White-labeled** — no client names, domains, tokens, or sample data.
- **Don't invent modules** — only paths present in `catalog.json`.
- **Copy, don't hand-write** — start from the nearest reference demo so the
  provider/kubeconfig/uplink wiring stays correct.
- If a requested feature has no matching module in `catalog.json`, say so — don't fake it.
