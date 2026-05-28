# Agent Guide — traefik-demo

Authoritative conventions for agents and contributors. Keep this file short and operational; deep dives belong in the per-section `AGENTS.md` files.

> `CLAUDE.md` files in this repo are thin pointers — the canonical content lives here and in the per-section `AGENTS.md`s. We use `AGENTS.md` because it's the cross-tool convention (Claude Code, Codex, Cursor, Gemini CLI, etc. all read it).

## What this repo is

A library of two kinds of building blocks consumed by **separate demo/POC repos**:

- **Terraform modules** via `source = "git::....git//<path>?ref=v<X.Y.Z>"`
- **Helm charts** via `helm install oci://ghcr.io/traefik-workshops/<chart> --version X.Y.Z`

Optimized for "stand up a demo fast," not production. Both halves are tagged from a single repo-wide `vX.Y.Z` and move in lockstep.

## What this repo is NOT

- A monorepo for demos. Don't put root configurations, `terraform.tfvars`, `.tfstate`, or `kind-config.yaml` here.
- A general-purpose module/chart library. If something doesn't fit one of the seven Terraform sections or isn't a Helm chart for a Traefik demo, push back and ask whether it belongs.

## Section ownership

### Terraform sections (under `terraform/`)

| Section | Belongs here | Does NOT belong here |
|---|---|---|
| `terraform/ai/` | LLM serving, vector DBs, AI-gateway dependencies | Generic k8s apps (use `terraform/tools/`), agents themselves |
| `terraform/apps/` | Sample workloads used to *demonstrate* infra (whoami, httpbin) | Real applications, anything that needs custom code |
| `terraform/compute/` | IaaS, managed k8s, base networking per cloud | Cluster add-ons (those go in `terraform/tools/`) |
| `terraform/observability/` | Metrics/logs/traces stacks | Generic Helm wrappers (tools), AI observability (ai) |
| `terraform/security/` | Identity providers, IAM scaffolding | Tools that happen to need a password (those stay in their section) |
| `terraform/tools/` | Cluster add-ons that aren't observability or security | Anything cloud-specific without a `k8s/` variant |
| `terraform/traefik/` | Traefik itself across platforms | Other ingress controllers (those go in `terraform/tools/nginx/k8s` etc.) |

### Helm section

| Section | Belongs here | Does NOT belong here |
|---|---|---|
| `helm/` | Helm charts published to `oci://ghcr.io/traefik-workshops` and consumed by demos | Application source code (`helm/airlines/services/` is historical debt — don't propagate), Terraform module wrappers around Helm releases (those live in `terraform/ai/`, `terraform/observability/`, etc.) |

When unsure which side something belongs to: if the demo *runs* this thing, it's a Helm chart; if the demo *provisions* the cluster or cloud resources, it's a Terraform module.

When unsure which Terraform section: ask the user.

## Module shape (canonical)

A leaf module should contain:

```
<module>/
├── main.tf       # resources
├── variables.tf  # inputs — every variable has type + description
├── outputs.tf    # outputs — every output has description; secrets marked sensitive
├── versions.tf   # terraform required_version + required_providers
└── README.md     # purpose, providers, vars, outputs, example usage
```

Optional, only when justified:

- `providers.tf` — *only* when the module needs configured provider blocks (e.g. aliases). Plain `required_providers` lives in `versions.tf`.
- `<topic>.tf` — split files by topic when `main.tf` exceeds ~300 lines (e.g. `kubeconfig.tf`, `metrics.tf`, `storage.tf`). Don't split prematurely.

The canonical convention: `versions.tf` holds `terraform { required_providers { ... } }`; `providers.tf` only exists when a module needs configured provider blocks (e.g. aliases). The repo's existing modules are now consistent with this; new modules follow it.

## Variable conventions

- **snake_case** for variable names. No exceptions.
- Every variable has `type` and `description`.
- Variables without sensible defaults should have no `default` (force the caller to provide).
- Feature toggles use `enable_<thing>` (boolean) — not `create_<thing>`, not `<thing>_enabled`, not implicit `count > 0`.
- The "thing being created" is named:
  - `name` for Helm-released apps in k8s modules
  - `cluster_name` for cluster modules
  - `<resource>_name` (e.g. `vm_name`, `vpc_name`) for IaaS resources
- Namespaces in k8s modules: `namespace` (string, default to the module name).
- Credentials/tokens are `sensitive = true` on both variable and any matching output.

## Output conventions

- Every output has `description`.
- Secrets (`*_password`, `*_token`, `*_key`, `*_secret`, `kubeconfig`) are `sensitive = true`.
- For cluster modules, expose at minimum: `host`, `cluster_ca_certificate`, `token` (or `kubeconfig`).
- For Helm-only wrappers where Helm exposes everything via `helm_release.this.status`, it's OK to have no `outputs.tf` — but the README must say so.

## Provider conventions

- Hashicorp providers: pin with `~>` to a major (e.g. `~> 5.0`).
- Third-party providers: pin with `~>` when possible; `>=` only when upstream doesn't follow semver.
- Never omit a version constraint. Floors with no ceiling cause silent breakage on fresh `terraform init`.
- `terraform { required_version = ">= 1.3" }` minimum for all modules.

## Defaults philosophy

A module should be runnable with the bare minimum of required inputs. That means:

- Pick the smallest reasonable instance/node size as the default.
- Default region/location to a common one (`us-east-1`, `eastus`, `us-central1`) — but force the caller to set it when the cost varies dramatically.
- Don't default to "production-grade" anything (HA, multi-AZ, encrypted-at-rest with a custom KMS key). Demos pay per-minute.
- Expose every "good-practice" knob via a variable so an advanced demo can opt in.

## Releases

Tags are immutable. **One repo-wide tag drives both Terraform and Helm.** Consumers pin to `?ref=vX.Y.Z` (Terraform) or `--version X.Y.Z` (Helm). See [`Makefile`](./Makefile):

- `make release-bug` → patch (non-breaking fix in any module or chart)
- `make release-feature` → minor (new module / new chart / new variable or value with default / additive output)
- `make release-major` → major (renamed/removed variable, changed default, renamed/removed value, removed module/chart)

Each release target:

1. Sweeps every `helm/*/Chart.yaml`'s `version:` (and in-repo subchart `version:` references) to the new repo version.
2. Commits the sweep.
3. Tags `vX.Y.Z` and pushes.
4. CI picks up the tag and publishes every chart to `oci://ghcr.io/traefik-workshops` at that version.

**A change is breaking if any downstream consumer would need to edit their `module {}` block or `values.yaml` to keep working.** When unsure, treat as breaking. Helm-specific breaking changes are listed in [`helm/AGENTS.md`](./helm/AGENTS.md#when-changing-an-existing-chart).

## When changing an existing module

1. Skim the relevant `<section>/AGENTS.md` for section-specific rules.
2. If you're changing a variable name, default, or removing an output → it's a major release.
3. If you're adding a variable, it must have a default (else minor becomes major).
4. Update the module's `README.md` (the per-module one, not the section one).
5. Run `make lint` before committing.

## When adding a new module or chart

Use one of the bundled skills:

- **`.claude/skills/new-module/`** — Terraform module under `<section>/<platform>/<name>`. Conversational prompt: *"Scaffold a new module under `<section>/<platform>/<name>` for `<one-line purpose>`."*
- **`.claude/skills/new-chart/`** — Helm chart under `helm/<name>`. Conversational prompt: *"Scaffold a new chart called `<name>` for `<one-line purpose>`."*

Both enforce the canonical shape and pin the new artifact's version to the current repo tag. Skills live in `.claude/skills/` so Claude auto-discovers them whenever this repo is the working directory.

## When cutting a release

Use **`.claude/skills/bump/`** (or `make release-bug/feature/major`). The skill handles the sweep-commit-tag-push dance and refuses to run from a dirty tree.

## Repo-wide expectations for agents

- **Don't rename existing variables** without explicit user approval — it's a breaking change and downstream demos will break.
- **Don't introduce a new provider** without explicit justification. The repo deliberately keeps the provider count low; stick to providers already in use unless there's a strong reason.
- **Don't commit `.tfstate`, `.tfvars`, or `.terraform/`.** `.gitignore` covers these but verify.
- **Don't bypass `make lint`.** If the lint catches something, fix the code, not the lint rule.
- **When asked to "add a module for X,"** check existing siblings under the same section first. If a similar one exists for a different platform, use it as the template.
- **When asked to "fix something across all modules,"** propose the change against one module first and get approval before fanning out.

## Where to look next

- **Agent's first read**: [`catalog.json`](./catalog.json) — every leaf TF module + Helm chart with required inputs, optional inputs, outputs, dependencies, descriptions. Regenerated by `make catalog`; CI fails on drift.
- Per-section conventions: `<section>/AGENTS.md`, [`helm/AGENTS.md`](./helm/AGENTS.md)
- Testing posture: [`TESTING.md`](./TESTING.md)
- Lint rules: [`.tflint.hcl`](./.tflint.hcl), [`.pre-commit-config.yaml`](./.pre-commit-config.yaml)
- Skills: [`new-module`](./.claude/skills/new-module/README.md), [`new-chart`](./.claude/skills/new-chart/README.md), [`bump`](./.claude/skills/bump/README.md), [`sa-assistant`](./.claude/skills/sa-assistant/SKILL.md)
- Slash commands: [`/extract-scenario`](./.claude/commands/extract-scenario.md), [`/preflight`](./.claude/commands/preflight.md), [`/build-poc`](./.claude/commands/build-poc.md), [`/snapshot-poc`](./.claude/commands/snapshot-poc.md)
- Cross-tool mirror: [`agents/`](./agents) — symlinks to `.claude/skills/` and `.claude/commands/` for non-Claude agents (Codex / Cursor / Gemini CLI).
