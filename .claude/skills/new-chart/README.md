# new-chart skill

Scaffolds a new Helm chart under `helm/<name>/` following the canonical layout in [`/helm/AGENTS.md`](../../../helm/AGENTS.md).

Two ways to use it:

## 1. Via Claude / any LLM-driven agent

If skill discovery is enabled in the repo, this loads automatically when the user says "scaffold a new chart," "create a chart for X," etc. The agent reads [`SKILL.md`](./SKILL.md), gathers name/purpose/kind/app-version from the user, then runs `scaffold.sh`.

## 2. Directly from the command line

```bash
.claude/skills/new-chart/scaffold.sh \
    --name vault-ui \
    --purpose "Web UI for the in-cluster Vault demo" \
    --kind app-with-ingress \
    --app-version 1.18.0
```

The script:

1. Validates name is kebab-case and `helm/<name>/` doesn't exist.
2. Picks a template based on `--kind`.
3. Substitutes placeholders.
4. Generates a starter `values.schema.json` from the templated `values.yaml`.
5. Pins `Chart.yaml` `version:` to the current repo tag (the unified versioning model).
6. Runs `helm lint --strict`.
7. Prints a next-steps checklist.

## Templates

| Kind | Files | Use when |
|---|---|---|
| `app` | Chart.yaml, values.yaml, values.schema.json, README, ct.yaml, .helmignore, templates/{_helpers.tpl, deployment.yaml, service.yaml, serviceaccount.yaml, NOTES.txt, tests/healthz.yaml} | Single-deployment app, exposed via in-cluster Service only |
| `app-with-ingress` | All of `app/` plus templates/ingressroute.yaml | Same, but also creates a Traefik IngressRoute gated on `ingress.enabled` |
| `library` | Chart.yaml (`type: library`), templates/_helpers.tpl | Pure templating library — no resources, only helpers other charts include |
| `wrapper` | Chart.yaml with `dependencies:`, values.yaml that passes through to the subchart | Thin wrapper around an upstream Helm chart with demo-friendly defaults |

## Editing the templates

If you change the canonical chart shape in `/helm/AGENTS.md`, update the templates here in the same commit. The pre-commit `helm-docs` hook keeps each chart's `<!-- BEGIN_HELM_DOCS -->` block fresh, but it doesn't fix structural drift.
