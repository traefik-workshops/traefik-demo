# bump skill

A thin wrapper over `make release-bug / release-feature / release-major` that does the full release sweep for the repo. The Makefile does the heavy lifting; this skill is the guardrail and the conversational interface.

## What a bump does

1. Refuses to run from a non-main branch or a dirty tree (without `FORCE=1`).
2. Computes the new tag (`vX.Y.Z`) from the current one.
3. **Sweeps three things to the new version:**
   - `helm/*/Chart.yaml` `version:` field
   - `file://` subchart dependency versions inside each `Chart.yaml`
   - `?ref=vX.Y.Z` example lines in every terraform leaf-module README
4. Runs `helm dep update` on every chart with subchart dependencies (refreshes `Chart.lock`).
5. Commits the sweep as `release(<label>): vX.Y.Z`.
6. Tags `vX.Y.Z` annotated, pushes branch + tag.
7. CI picks up the tag and publishes every chart to `oci://ghcr.io/traefik-workshops`.

## Use it via the skill

```
@bump
```

(Or just describe the release: *"Cut a patch release"* / *"Bump for the new EKS module"* / *"Ship the breaking value rename in keycloak"*.)

The skill asks you the kind (patch/minor/major), previews the new tag, shows the commit log since the last tag, and runs `make release-*` after explicit confirmation.

## Use it from the CLI

If you'd rather skip the skill:

```bash
make release-preview      # see what the next tag would be for each kind
make release-bug          # patch
make release-feature      # minor
make release-major        # major
```

The Makefile also prompts for confirmation before tagging.

## Why a skill on top of the Makefile

Two reasons:

1. **Conversational confirmation** — agents (and humans) are more likely to pause and read the commit log when an LLM is asking "is this really a minor?"
2. **Refuse on ambiguity** — if the recent commit log is ambiguous between two bump kinds, the skill stops and asks. The Makefile happily picks whatever you told it.

