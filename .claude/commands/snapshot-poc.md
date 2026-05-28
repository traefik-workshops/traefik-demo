# Snapshot PoC

SA confirms the PoC is running and the prospect is happy. Collect all artifacts, render a human-readable summary, and push to a dedicated git repository that can be shared with the prospect.

## Invocation

```
/snapshot-poc
/snapshot-poc <path-to-poc.yaml>
```

With no argument: reads `poc.yaml` from the current working directory.

## Step 1 — Verify deployment

Read `deployment.status` from `poc.yaml`. If `rendered` (not deployed): ask SA to confirm whether to snapshot anyway (useful for render-only reviews). If `failed`: warn and ask SA to confirm before snapshotting a partial deployment.

## Step 2 — Collect artifacts

Gather:
- `poc.yaml` — the full progressive build record
- `~/poc-scenarios/<slug>/manifests/` — all rendered Terraform + Helm files
- `~/poc-scenarios/<slug>/intake/normalized.md` — source material

Redact all sensitive values from `inputs.vars` (`sensitive: true`) in all files before writing to snapshot.

## Step 3 — Generate DEMO.md

Write a human-readable summary to `~/poc-scenarios/<slug>/DEMO.md`:

```markdown
# PoC — <Prospect Name>

**Date**: <YYYY-MM-DD>
**Cloud**: <provider>
**Industry**: <industry>

## What was built

<one paragraph: scenario, modules used, what the prospect can see>

## Architecture

| Layer | Module / Chart | Purpose |
|---|---|---|
| Cluster | terraform/compute/<path> | <description> |
| Gateway | terraform/traefik/k8s | Traefik Hub — API gateway |
| Auth | terraform/security/<path> | <IdP name> |
| ... | ... | ... |

## Access points

| Service | URL |
|---|---|
| Traefik Dashboard | https://... |
| <other services> | https://... |

## Reproduce this PoC

See `manifests/` for all rendered Terraform and Helm invocations.
All sensitive values (tokens, passwords) are redacted — SA holds the originals.
```

## Step 4 — Discuss git push with SA

```
Snapshot ready at: ~/poc-scenarios/<slug>/

Contents:
  DEMO.md          — human-readable summary
  poc.yaml         — full build record (sensitive values redacted)
  manifests/       — rendered Terraform + Helm files
  intake/          — normalized source documents

Push to a git repo?
  1. Push to existing repo: <url>
  2. Create new repo and push (provide org/name)
  3. Keep local only
```

Wait for SA choice.

## Step 5 — Push to git (if SA chose)

```bash
cd ~/poc-scenarios/<slug>
git init
git add .
git commit -m "PoC snapshot — <prospect name> — <date>"
git remote add origin <repo-url>
git push -u origin main
```

If repo doesn't exist yet and SA chose "create new": use `gh repo create` with SA-provided org/name, then push.

## Step 6 — Append to poc.yaml

```yaml
snapshot:
  timestamp: <ISO-8601>
  status: pushed             # pushed | local-only
  repo: <repo-url or "">
  demo_md: ~/poc-scenarios/<slug>/DEMO.md
  sensitive_values: redacted
```

## Rules

- Never commit raw secrets — redact all `sensitive: true` values before any git operation.
- Never push without SA confirmation.
- If repo already contains a snapshot for this prospect: do not force-push — create a new branch named `<date>-<slug>` and let SA decide.
