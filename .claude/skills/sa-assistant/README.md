# sa-assistant skill

Guides a Solution Architect through building a Traefik Hub PoC for a prospect — from raw intake material to a running demo.

## When to use

Tell Claude: *"build a PoC for [prospect]"*, *"I have a prospect transcript"*, *"set up a demo for [company]"*.

Claude activates this skill and drives the full 7-step loop. See [`SKILL.md`](./SKILL.md) for the workflow and decision rules.

## Key files

| File | Purpose |
|---|---|
| [`SKILL.md`](./SKILL.md) | Agent instructions — workflow, decision rules, persona |
| [`poc-schema.md`](./poc-schema.md) | poc.yaml schema + worked example — single source of truth |
| [`/intake`](../../commands/intake.md) | Normalize raw prospect material |
| [`/extract-scenario`](../../commands/extract-scenario.md) | Extract signals from normalized doc |
| [`/feasibility-check`](../../commands/feasibility-check.md) | Map signals → modules, identify required inputs |
| [`/preflight`](../../commands/preflight.md) | Module integrity validation (fmt + validate) |
| [`/collect-inputs`](../../commands/collect-inputs.md) | Interactive loop to gather all credentials and module vars |
| [`build-poc`](../build-poc/SKILL.md) | Deploy skill — reasoning + Terraform + Helm |
| [`/snapshot-poc`](../../commands/snapshot-poc.md) | Capture artifacts, generate DEMO.md, push to git |
| [`catalog.json`](../../../catalog.json) | Module + chart index (machine-readable, CI-gated) |
| [`CATALOG.md`](../../../CATALOG.md) | Module + chart index (human-readable) |

## Test fixtures

[`fixtures/`](../../../fixtures/) — three prospect scenarios (AWS/fintech, Azure/healthcare, GCP/e-commerce). Use them to validate the skill end-to-end.
