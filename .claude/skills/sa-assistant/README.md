# sa-assistant skill

Guides a Solution Architect through building Traefik Hub demos and PoCs — either by deriving
the stack from raw prospect material, or by building a known stack directly.

## When to use

Two entry points (see [`SKILL.md`](./SKILL.md) for the full workflow and decision rules):

- **Prospect-analysis flow** — *"build a PoC for [prospect]"*, *"I have a prospect
  transcript"*, *"set up a demo for [company]"*. Drives the full 7-step loop from raw intake
  material to a running demo.
- **Direct build** — *"create a demo with the AI gateway and Grafana"*, *"spin up a
  standalone multi-cluster PoC repo"*. A short questionnaire renders a composition with
  automated tests via [`/create-demo`](../../commands/create-demo.md) (in-repo) or
  [`/create-poc`](../../commands/create-poc.md) (standalone repo).

## Key files

| File | Purpose |
|---|---|
| [`SKILL.md`](./SKILL.md) | Agent instructions — both workflows, decision rules, persona |
| [`poc-schema.md`](./poc-schema.md) | poc.yaml schema + worked example — single source of truth |
| [`demo-spec.md`](./demo-spec.md) | Direct-build spec — questionnaire, config→module mapping, layout, tests (shared by `/create-demo` + `/create-poc`) |
| **Prospect-analysis flow** | |
| [`/intake`](../../commands/intake.md) | Normalize raw prospect material |
| [`/extract-scenario`](../../commands/extract-scenario.md) | Extract signals from normalized doc |
| [`/feasibility-check`](../../commands/feasibility-check.md) | Map signals → modules, identify required inputs |
| [`/preflight`](../../commands/preflight.md) | Module integrity validation (fmt + validate) |
| [`/collect-inputs`](../../commands/collect-inputs.md) | Interactive loop to gather all credentials and module vars |
| [`build-poc`](../build-poc/SKILL.md) | Deploy skill — reasoning + Terraform + Helm |
| [`/snapshot-poc`](../../commands/snapshot-poc.md) | Capture artifacts, generate DEMO.md, push to git |
| **Direct build** | |
| [`/create-demo`](../../commands/create-demo.md) | Generic demo under `demos/` — relative sources, CI-wired |
| [`/create-poc`](../../commands/create-poc.md) | Standalone PoC repo — pinned `?ref=<tag>` + getting-started walkthrough |
| **Indexes** | |
| [`catalog.json`](../../../catalog.json) | Module + chart index (machine-readable, CI-gated) |
| [`CATALOG.md`](../../../CATALOG.md) | Module + chart index (human-readable) |

## Test fixtures

[`fixtures/`](../../../fixtures/) — synthetic prospect conversations for validating the skill end-to-end: three deployable scenarios (AWS/fintech, Azure/healthcare, GCP/e-commerce) plus two negative tests (wrong recipient, fictional product). Run via `/extract-scenario fixtures/example-1/transcript.md`.
