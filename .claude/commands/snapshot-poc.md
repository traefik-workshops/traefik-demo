# Snapshot PoC

Capture what was deployed for the prospect record. Run after all modules deployed successfully.

## Invocation

```
/snapshot-poc
```

Reads the current deploy context (prospect name, modules deployed, outputs).

## Output location

Write to `~/poc-snapshots/<prospect-name>-<YYYY-MM>/` — always outside this repo.

If the directory does not exist, create it. One snapshot per prospect+month — do not overwrite existing snapshots.

## Snapshot structure

```
demo-snapshots/<prospect-name>-<YYYY-MM>/
  DEMO.md          ← human-readable summary
  modules.tf       ← exact module sources + versions used
  inputs.tfvars    ← all var values used (passwords/tokens redacted)
  outputs.md       ← endpoints, URLs, credentials produced
```

## DEMO.md template

```markdown
# PoC — <Prospect Name>

**Date**: <YYYY-MM-DD>
**Cloud**: <provider>
**Built by**: SA agent

## What was deployed

<one paragraph describing the scenario>

## Modules used

| Module | Purpose |
|---|---|
| compute/PROVIDER/VARIANT | cluster type |
| traefik/shared | Traefik Hub |
| security/MODULE | identity provider |

## Access points

| Service | URL | Notes |
|---|---|---|
| Traefik Dashboard | https://... | admin/admin |
| Keycloak | https://... | |

## Credentials

See inputs.tfvars (passwords redacted in this file).
```

## Rules

- Never store raw secrets — redact or omit all passwords, tokens, API keys
- One snapshot per prospect+month — do not overwrite existing snapshots
