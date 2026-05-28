---
name: new-chart
description: Scaffold a new Helm chart under helm/ in the traefik-demo repo following the canonical layout. Use when the user asks to "add a chart," "create a chart," "scaffold a chart," "new helm chart for X," or similar phrases that imply creating a new chart in helm/.
---

# new-chart skill

You are scaffolding a new Helm chart under `helm/<name>/`. The chart conforms to the conventions in [`/helm/AGENTS.md`](../../helm/AGENTS.md) on first commit — no follow-up lint fixups required. The new chart's `Chart.yaml` `version:` is pinned to the current repo tag (the unified versioning model — see [`/AGENTS.md`](../../AGENTS.md)).

## Gather requirements first

Before invoking the scaffold script, use the AskUserQuestion tool to gather:

1. **Name** — kebab-case directory name (`my-chart`, not `MyChart`). Validate it doesn't already exist at `helm/<name>/`.
2. **One-line purpose** — written to `Chart.yaml` `description:` and the chart's README.
3. **Chart kind** — one of:
   - `app` — typical application chart (Deployment + Service + NOTES.txt + values.schema.json). Default.
   - `app-with-ingress` — `app` plus a Traefik `IngressRoute` template gated by `ingress.enabled`.
   - `library` — `type: library`, no resources, just helpers in `_helpers.tpl`. Used by other charts.
   - `wrapper` — pure Helm wrapper around an upstream chart (just `dependencies:` in Chart.yaml + thin values pass-through).
4. **App version** — the upstream app's release string (e.g. `1.2.3`, `v1.2.3` if upstream uses the v-prefix, `2026.2.0` for date-like). Not the same as chart version.

If the user is adding a chart that's clearly a variant of an existing one (e.g. another vector store, another postgres flavor), stop and check: does it really warrant a new chart, or should it be a feature flag on the existing chart? Only proceed if it's genuinely a new system.

## Then run the scaffold script

```
.claude/skills/new-chart/scaffold.sh \
    --name <name> \
    --purpose "<one-line>" \
    --kind <app|app-with-ingress|library|wrapper> \
    --app-version <X.Y.Z>
```

The script:

1. Refuses to run if `helm/<name>/` already exists.
2. Picks a template based on `--kind`.
3. Copies template files, substituting `{{NAME}}` / `{{PURPOSE}}` / `{{APP_VERSION}}` / `{{REPO_VERSION}}` (read from the latest `v*` git tag).
4. Generates a starter `values.schema.json` from the templated `values.yaml`.
5. Runs `helm lint --strict` to confirm the new chart parses.
6. Prints the next-steps checklist.

If `helm` isn't on PATH the script still scaffolds but skips lint with a warning.

## After scaffolding — what you still do

1. **Fill in `# TODO(new-chart):` markers** in `values.yaml` and `templates/*.yaml`. The defaults are minimal — adjust to match the upstream Helm chart you're wrapping or the resource shape you want.
2. **Hand-edit `values.schema.json`** to add `description:` fields and tighten any `additionalProperties: false` boundaries that should be enforced.
3. **Update `NOTES.txt`** with the real post-install URLs, credentials, and commands. The stub is generic.
4. **Add a row to `helm/README.md`'s charts table** with the new chart's name, purpose, and `appVersion`.
5. **Pick a test tier from [`/TESTING.md`](../../TESTING.md#helm)** (default `Install`). Add a `templates/tests/<probe>.yaml` Helm test.
6. **Run `make check`** before committing. If helm-lint or kubeconform fails, fix the chart, not the lint rule.
7. **Tell the user this is a release-feature bump** — adding a chart is additive, so it ships in the next minor release.

## Don't

- Don't scaffold without asking the four questions. The defaults are deliberately wrong so the skill doesn't run on autopilot.
- Don't write outside `helm/<name>/` (and the one-line addition to `helm/README.md`).
- Don't edit `Chart.yaml` `version:` after scaffolding — the release flow owns that field. Edit only `appVersion` if the upstream app changes.
- Don't default a real credential. Use a placeholder + a `NOTES.txt` instruction.
- Don't pull in a new top-level dependency (helm subchart, new CRD requirement) without flagging it explicitly in the PR.
- Don't put application source code in the chart directory. `helm/airlines/services/` is historical debt — don't propagate.

## When to refuse

- Chart name isn't kebab-case lowercase.
- Chart already exists at `helm/<name>/`.
- User asked for a chart that's clearly a variant of an existing one (extend it instead).
- User asked for something that's not a Helm chart (a script, a docs page, a workflow file).
- User asked for the chart to live outside `helm/` (e.g. at repo root). This skill only writes under `helm/`.
