---
name: bump
description: Cut a release of the traefik-demo repo. Bumps the repo tag (patch/minor/major), sweeps every helm chart version + in-repo dependency version + terraform README ref examples to match, refreshes Chart.lock files, commits, tags, pushes. Use when the user says "release," "cut a release," "tag," "bump the version," "ship," or similar.
---

# bump skill

You are cutting a release of the traefik-demo repo. The repo uses a **single unified semver tag** (`vX.Y.Z`) that drives both halves:

- Terraform consumers pin to `?ref=vX.Y.Z`
- Helm consumers pin to `--version X.Y.Z`
- Every `helm/<chart>/Chart.yaml` `version:` matches the repo tag
- In-repo `file://` subchart dep versions also match the repo tag
- Terraform leaf-module READMEs show `?ref=vX.Y.Z` in their usage examples

When you bump, all of the above move together in one commit + one tag.

## Step 0 — confirm the user actually wants to release

The `bump` skill is irreversible (tags get pushed to origin). Before doing anything, **always confirm**:

1. **Bump kind** — patch (bug fix), minor (additive feature), or major (breaking change). Ask via the AskUserQuestion tool. Use the framing from `/CONTRIBUTING.md`:
   - `patch` — non-breaking fix in a module or chart
   - `minor` — new module, new chart, new variable / value with a default, additive output
   - `major` — renamed/removed variable, renamed/removed value, changed default, removed module/chart, bumped pinned provider major
2. **Confirm intent** — show the commit log since the last tag and ask "Cut `<new_tag>` now?"

If unsure whether something is breaking, default to **major**. Downstream demos pin tags; a wrong minor-vs-major call causes silent drift on the next `helm install` or `terraform init`.

## Step 1 — run `make release-<kind>` (the script does the rest)

The Makefile target does the full flow:

```bash
make release-bug       # patch
make release-feature   # minor
make release-major     # major
```

Internally, each target:

1. Refuses if branch is not `main` (override with `FORCE=1`).
2. Refuses if working tree is dirty (override with `FORCE=1`).
3. Pulls latest from `origin`.
4. Computes the new tag from the current one.
5. **Sweeps** `helm/*/Chart.yaml` `version:` to the new version.
6. **Sweeps** in-repo `file://` subchart dep versions inside each `Chart.yaml`.
7. **Sweeps** every terraform leaf-module README `?ref=vX.Y.Z` example line.
8. Runs `helm dep update` on every chart with `dependencies:` (refreshes `Chart.lock`).
9. Commits the sweep + locks as `release(<label>): vX.Y.Z`.
10. Tags `vX.Y.Z` annotated.
11. Pushes both the branch and the tag to `origin`.

CI picks up the tag and publishes every chart to `oci://ghcr.io/traefik-workshops/<chart>:X.Y.Z`.

## What you (the agent) actually do

1. Call AskUserQuestion to ask: "What kind of release?" with options patch/minor/major.
2. Run `make release-preview` so the user sees what the next tag will be.
3. Show the user `git log --oneline <current-tag>..HEAD` so they can verify the bump kind matches the changes.
4. **Confirm explicitly** — "Cut `<new-tag>`? This will commit + push + tag."
5. Only after explicit confirmation, run `make release-<kind>`. The Makefile target also asks for confirmation — that's a second safety net.
6. Report the result: tag pushed, what CI will now do, where the published artifacts will land.

## Bypass switches (only when explicitly asked)

The Makefile supports two overrides — never use them without the user asking:

- `FORCE=1` — allow release from a non-main branch or with a dirty working tree. Used for hotfix branches.
- `YES=1` — skip the interactive "Tag and push?" prompt. Used in automation.

If the user asks for either, confirm you understand why before passing them.

## Don't

- **Don't bump without confirming the kind.** Major-vs-minor is a real call; the user has to make it.
- **Don't run any sweeps manually.** The Makefile owns the sweep so the commit-message format and ordering are consistent.
- **Don't tag without pushing.** Local-only tags drift from origin and confuse future bumps.
- **Don't run `make release-*` from a feature branch** without `FORCE=1` and a very good reason.
- **Don't bump if there are unreleased breaking changes you're labeling as minor.** Default to major.
- **Don't bump while another release PR is open** — wait for it to merge first.

## When to refuse

- User asked to "tag" without specifying the kind, and the recent commits are ambiguous between patch and minor or minor and major. Push back and ask.
- Working tree is dirty and the user can't articulate why `FORCE=1` is needed.
- Branch is not `main` and the user doesn't have a hotfix justification.
- User asked to bump to an arbitrary version (e.g. `v5.0.0` when current is `v3.2.0`). The Makefile only bumps by one increment; jumping versions requires a manual `git tag` and is rarely a good idea.

## After the bump

Tell the user:

- The new tag is `vX.Y.Z`.
- CI (`helm-publish.yml`) is now packaging every chart at version `X.Y.Z` and pushing to `ghcr.io/traefik-workshops`.
- Downstream demos can pick up the change with `?ref=vX.Y.Z` (Terraform) or `--version X.Y.Z` (Helm).
- If the release was major, demos pinning the previous major will keep working — they need a deliberate bump.
