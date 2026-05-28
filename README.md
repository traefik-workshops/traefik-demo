# traefik-demo

Shared Terraform modules used by other repos to **build demos and POCs**. Every module here is consumed via `source = "git::..."` from one or more demo repos and is expected to have sensible defaults so a demo author can `module "x" { source = "..." }` with minimal configuration, while still exposing knobs for advanced scenarios.

This is **not** a production-ready module library. The bar is: "an SA can stand up a credible demo in under an hour." Trade-offs are made accordingly — opinionated defaults over flexibility, recent-version Helm charts over patched-stable ones, single-cluster simplicity over multi-region resilience.

---

## Working with AI in this repo

| You are… | Entry point |
|---|---|
| SA building a prospect demo | Activate the `sa-assistant` skill: *"build a PoC for [prospect]"* or *"I have a prospect transcript"* |
| Dev adding a module or chart | Read [`CONTRIBUTING.md`](./CONTRIBUTING.md), then use the `new-module` or `new-chart` skill |
| Cutting a release | Use the `bump` skill or `make release-bug/feature/major` |

Full SA workflow: `/intake` → `/extract-scenario` → `/feasibility-check` → `/preflight` → `/collect-inputs` → `build-poc` → `/snapshot-poc`.
See [`sa-assistant` skill](./.claude/skills/sa-assistant/README.md) for the step-by-step flow and key files.

---

## Layout

This repo holds two kinds of building blocks consumed by demos:

```
.
├── terraform/      # Terraform modules
│   ├── ai/             # models, vector stores, AI gateway dependencies
│   ├── apps/           # sample workloads (whoami, httpbin) across platforms
│   ├── compute/        # IaaS + managed Kubernetes per cloud (AWS, Azure, GCP, ...)
│   ├── observability/  # Grafana, Prometheus, Loki, Tempo, Langfuse, OpenTelemetry
│   ├── security/       # IdPs (Cognito, EntraID, Keycloak), instance principals
│   ├── tools/          # cluster add-ons (ArgoCD, cert-manager, ingress, k6, ...)
│   └── traefik/        # Traefik installs per platform (EC2, ECS, k8s, Nutanix)
├── helm/           # Helm charts (ai-gateway, airlines, dns-traefiker, ...) published to OCI
├── catalog.json    # machine-readable index of every module + chart (regenerated via `make catalog`)
├── scripts/        # repo tooling — discover.py (builds catalog.json), release helpers
├── agents/         # tool-agnostic mirror of .claude/ (skills + commands) for Codex/Cursor/Gemini
└── .claude/        # Agent assets: skills (new-module, new-chart, bump, sa-assistant) + slash commands
```

Inside each Terraform section, modules are organized by **platform** (`k8s/`, `aws/`, `nutanix/`, `runpod/`, ...). A *leaf module* is any directory containing `.tf` files directly — 70 of them. The `helm/` directory holds 7 charts. [`catalog.json`](./catalog.json) is the regenerated, machine-readable index of all of them.

Each section has its own `README.md` and `AGENTS.md` — start with those when you want a focused view.

## Quick links

- [Layout, conventions, and module patterns](./AGENTS.md) — read this first if you're contributing
- [Testing strategy](./TESTING.md) — what's tested, what isn't, why
- [Contributing guide](./CONTRIBUTING.md) — how to add a module or chart
- Terraform sections: [ai](./terraform/ai/README.md) · [apps](./terraform/apps/README.md) · [compute](./terraform/compute/README.md) · [observability](./terraform/observability/README.md) · [security](./terraform/security/README.md) · [tools](./terraform/tools/README.md) · [traefik](./terraform/traefik/README.md)
- Helm charts: [helm/](./helm/README.md)
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

## Releases

This repo uses **a single repo-wide semver tag** (`vMAJOR.MINOR.PATCH`) that drives both halves:

- Terraform consumers pin to `?ref=vX.Y.Z`.
- Helm consumers pin to `--version X.Y.Z` (every `helm/*/Chart.yaml`'s `version:` is rewritten to match before tagging).

```bash
make release-bug      # patch: non-breaking fix (Terraform or Helm)
make release-feature  # minor: new module / chart / value with default
make release-major    # major: breaking change (renamed variable, removed value, changed default)
```

A change is breaking if any consumer would need to edit their `module {}` block or `values.yaml` to keep working. When in doubt, treat as breaking.

See [`Makefile`](./Makefile) for the full target list. Run `make help`.

## What goes in this repo

**Yes:**
- A reusable module that produces a usable demo artifact (a cluster, a Helm-installed app, a configured Traefik install).
- Defaults tuned for "smallest credible demo" — small node pools, free-tier-friendly sizes where possible.

**No:**
- The actual demo. Demos live in their own repos and consume this one.
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
