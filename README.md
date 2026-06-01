# traefik-demo

Shared **Terraform modules** and **Helm charts** that other repos consume to **build demos and POCs**. Both halves ship from a single repo-wide tag (`vX.Y.Z`) and move in lockstep — Terraform via `source = "git::...?ref=vX.Y.Z"`, Helm via `--version X.Y.Z` from `oci://ghcr.io/traefik-workshops`. Every artifact ships sensible defaults so a demo author can wire it up with minimal configuration, while still exposing knobs for advanced scenarios.

This is **not** a production-ready module library. The bar is: "an SA can stand up a credible demo in under an hour." Trade-offs are made accordingly — opinionated defaults over flexibility, recent-version Helm charts over patched-stable ones, single-cluster simplicity over multi-region resilience.

---

## Working with AI in this repo

| You are… | Entry point |
|---|---|
| SA building a prospect demo | Activate the `sa-assistant` skill: *"build a PoC for [prospect]"* or *"I have a prospect transcript"* |
| Dev adding a module or chart | Read [`CONTRIBUTING.md`](./CONTRIBUTING.md), then use the `new-module` or `new-chart` skill |
| Cutting a release | Use the `bump` skill or `make release-bug/feature/major` |

Full SA workflow: `/intake` → `/extract-scenario` → `/feasibility-check` → `/preflight` → `/collect-inputs` → `build-poc` → `/snapshot-poc`.
See the [`sa-assistant` skill](./.claude/skills/sa-assistant/SKILL.md) for the step-by-step flow and key files.

---

## Layout

```
.
├── terraform/      # Terraform modules (70 leaf modules), organized by section → platform
│   ├── ai/             # models, vector stores, AI-gateway dependencies (Ollama, NIMs, Milvus, Weaviate, Presidio, ...)
│   ├── apps/           # sample workloads (whoami, httpbin)
│   ├── compute/        # IaaS + managed Kubernetes per cloud (AWS, Azure, GCP, OCI, Akamai, DigitalOcean, Nutanix, SUSE/k3d, RunPod)
│   ├── observability/  # Grafana stack, Prometheus, Loki, Tempo, Langfuse, OpenTelemetry
│   ├── security/       # IdPs (Cognito, EntraID, Keycloak), OCI instance principals
│   ├── tools/          # cluster add-ons (ArgoCD, cert-manager, nginx, k6, redis, postgresql, ...)
│   └── traefik/        # Traefik + Hub installs per platform (EC2, ECS, k8s, Nutanix, cloud-init)
├── helm/           # Helm charts (7) published to oci://ghcr.io/traefik-workshops
├── demos/          # runnable, white-labeled compositions of the library (k3d + cloud); CI-tested
├── fixtures/       # synthetic prospect transcripts for testing the sa-assistant skill
├── catalog.json    # machine-readable index of every module + chart (make catalog)
├── CATALOG.md      # human-readable module index by section, with common PoC stacks (make catalog-markdown)
├── signals.yaml    # keyword index mapping prospect lingo → modules (used by /extract-scenario)
├── scripts/        # repo tooling — discover.py (builds catalog.json), catalog_markdown.py, reference.sh
├── agents/         # tool-agnostic mirror of .claude/ (skills + commands) for Codex/Cursor/Gemini
└── .claude/        # Agent assets: skills (new-module, new-chart, bump, sa-assistant, build-poc) + slash commands
```

Inside each Terraform section, modules are organized by **platform** (`k8s/`, `aws/`, `nutanix/`, `runpod/`, ...). A *leaf module* is any directory containing `.tf` files directly — 70 of them. The `helm/` directory holds 7 charts. [`catalog.json`](./catalog.json) is the regenerated, machine-readable index of all of them; [`CATALOG.md`](./CATALOG.md) is the human-readable view.

Each section has its own `README.md` and `AGENTS.md` — start with those when you want a focused view.

## Quick links

- [Layout, conventions, and module patterns](./AGENTS.md) — read this first if you're contributing
- [Module + chart catalog](./CATALOG.md) — scannable index by section, with common PoC stacks
- [Testing strategy](./TESTING.md) — what's tested, what isn't, why
- [Contributing guide](./CONTRIBUTING.md) — how to add a module or chart
- Terraform sections: [ai](./terraform/ai/README.md) · [apps](./terraform/apps/README.md) · [compute](./terraform/compute/README.md) · [observability](./terraform/observability/README.md) · [security](./terraform/security/README.md) · [tools](./terraform/tools/README.md) · [traefik](./terraform/traefik/README.md)
- Helm charts: [helm/](./helm/README.md) · Demos: [demos/](./demos/README.md) · Fixtures: [fixtures/](./fixtures/README.md)
- Agent skills (dev): [`new-module`](./.claude/skills/new-module/README.md), [`new-chart`](./.claude/skills/new-chart/README.md), [`bump`](./.claude/skills/bump/README.md)
- Agent skills (SA): [`sa-assistant`](./.claude/skills/sa-assistant/SKILL.md), [`build-poc`](./.claude/skills/build-poc/SKILL.md)
- Slash commands: [`/intake`](./.claude/commands/intake.md), [`/extract-scenario`](./.claude/commands/extract-scenario.md), [`/feasibility-check`](./.claude/commands/feasibility-check.md), [`/preflight`](./.claude/commands/preflight.md), [`/collect-inputs`](./.claude/commands/collect-inputs.md), [`/snapshot-poc`](./.claude/commands/snapshot-poc.md)

## Consuming an artifact

Terraform module:

```hcl
module "eks" {
  source = "git::https://github.com/<org>/traefik-demo.git//terraform/compute/aws/eks?ref=v4.0.0"

  cluster_name     = "demo"
  cluster_location = "us-east-1"
  eks_version      = "1.30"
}
```

Helm chart (published to OCI on every tag):

```bash
helm install my-airlines oci://ghcr.io/traefik-workshops/airlines --version 4.0.0
```

**Always pin `?ref=<tag>` and `--version <tag>`** — never consume from `main` / `latest`. Tags are immutable; `main` is not.

## Demos

[`demos/`](./demos/README.md) holds runnable, white-labeled compositions of the library — the reference shapes the `sa-assistant` / `build-poc` skills pattern-match against. Module sources are **relative** so each demo tracks this checkout and validates offline. Four run end-to-end on k3d for free (`make up` / `make scenarios` / `make down`); one targets AWS:

- [`single-cluster`](./demos/single-cluster) — one k3d cluster + Traefik Hub + whoami (the "hello world")
- [`k3d-unified-ingress`](./demos/k3d-unified-ingress) — multicluster transit + workload (the dominant real-world shape)
- [`ai-gateway-openai`](./demos/ai-gateway-openai) — AI Gateway over an OpenAI-compatible backend with Presidio content-guards + a token rate-limit
- [`hub-from-source`](./demos/hub-from-source) — Traefik Hub built from local source on k3d (the dev loop for testing a Hub change)
- [`oidc-portal`](./demos/oidc-portal) — Traefik Hub API Portal + Cognito on EKS (cloud; swap for EntraID or Keycloak)

The four k3d demos are deployed and smoke-tested in CI; `oidc-portal` is cloud, so CI only `terraform validate`s it.

## Local development

Everything runs through the [`Makefile`](./Makefile) — `make help` lists every target:

```bash
make check              # full CI suite, no cluster needed: fmt-check, tf-validate, tf-lint, tf-security,
                        # helm-lint, helm-template (kubeconform vs. Traefik + Hub schemas), catalog drift
make preflight          # fast pre-deploy check — fmt + lint, no cloud creds
make catalog            # regenerate catalog.json from the tree
make catalog-markdown   # regenerate CATALOG.md from catalog.json
make e2e                # full ladder, incl. installing every chart on a throwaway k3d cluster (needs k3d + ct)
```

CI runs `make check` plus the demo deploy/scenario workflow on every PR; both `catalog.json` and `CATALOG.md` are drift-gated, so regenerate them after adding a module or chart.

## Traefik + Hub config & CRD reference

Don't guess `traefik.io` / `hub.traefik.io` fields. The authoritative, versioned, field-level reference for everything Traefik + Hub (CRDs, middlewares, providers, static config) lives in the private **`traefik/reference`** repo and is consumed on demand by [`scripts/reference.sh`](./scripts/reference.sh) — nothing is vendored here (this repo is public).

```bash
make reference PAGE=hub/crd/apiplan   # look up a concept (also oss/middlewares/jwt, hub/middlewares/oidc, INDEX)
make helm-template                    # render every chart + validate the emitted Traefik/Hub CRs against the
                                      # real JSON Schemas with kubeconform (part of `make check`)
make reference-schemas                # just refresh the schema cache (.reference/, gitignored)
```

Needs `gh auth login` with read access to `traefik/reference`. Unauthenticated, every entry point degrades gracefully — it prints how to authenticate, then continues *without* the reference rather than blocking. Pin a snapshot with `REFERENCE_REF=<sha>`.

## Releases

This repo uses **a single repo-wide semver tag** (`vMAJOR.MINOR.PATCH`) that drives both halves:

- Terraform consumers pin to `?ref=vX.Y.Z`.
- Helm consumers pin to `--version X.Y.Z` (every `helm/*/Chart.yaml`'s `version:` is rewritten to match before tagging).

```bash
make release-bug      # patch: non-breaking fix (Terraform or Helm)
make release-feature  # minor: new module / chart / value with default
make release-major    # major: breaking change (renamed variable, removed value, changed default)
```

A change is breaking if any consumer would need to edit their `module {}` block or `values.yaml` to keep working. When in doubt, treat as breaking. Run `make release-preview` to see the next tag for each kind.

## What goes in this repo

**Yes:**
- A reusable module that produces a usable demo artifact (a cluster, a Helm-installed app, a configured Traefik install).
- Defaults tuned for "smallest credible demo" — small node pools, free-tier-friendly sizes where possible.

**No:**
- The actual demo. Demos live in their own repos and consume this one (the in-repo [`demos/`](./demos) are white-labeled compositions for CI and skill pattern-matching, not customer deliverables).
- Anything that requires hand-holding to install (manual steps, missing inputs without defaults, secrets without a managed source).
- Anything that hardcodes credentials.

## Adding a module or chart

Use the bundled skills:

```
@new-module   # scaffold a Terraform module under terraform/<section>
@new-chart    # scaffold a Helm chart under helm/
@bump         # cut a release (sweeps Chart.yaml versions, tags, pushes)
```

Each skill asks you what's needed and scaffolds the canonical layout in [`AGENTS.md`](./AGENTS.md). Skills live in [`.claude/skills/`](./.claude/skills) so Claude auto-discovers them whenever this repo is the working directory.

If you're scaffolding by hand, copy the closest existing sibling module / chart — patterns are not invented per-section.
