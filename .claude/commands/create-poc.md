# Create PoC

Scaffold a **standalone, prospect-facing PoC** in its own git repo — the same kind of
Traefik Hub composition `/create-demo` produces, but pinned to a released library version,
de-coupled from this repo, and wrapped in a hand-holding getting-started walkthrough you can
hand to a prospect.

Use this when someone says *"create a PoC for X"*, *"build a standalone demo repo"*,
*"spin up a takeaway repo for the prospect"*. To add a demo **inside this repo** (relative
sources, CI-tested alongside the others), use [`/create-demo`](./create-demo.md) instead.

> Read [`sa-assistant/demo-spec.md`](../skills/sa-assistant/demo-spec.md) first — the
> questionnaire, config→module mapping, layout, and test convention are shared with
> `/create-demo`. This command adds the **separate-repo, pinned-source, hand-holding** rules
> on top, and follows the pinning convention in
> [`build-poc/SKILL.md`](../skills/build-poc/SKILL.md).

## Invocation

```
/create-poc
/create-poc <name>                       # pre-seed the PoC name
/create-poc <name> --dest <path>         # where to create the repo (default: ~/poc-scenarios/<name>)
```

If the user already ran the prospect-analysis flow (`/intake` → … → `/collect-inputs`) and
has a `poc.yaml`, read the resolved `feasibility.modules` / `charts` / `inputs` from it
instead of re-asking the questionnaire — this command is the direct-build shortcut for when
there is no transcript to analyze.

## Step 1 — Gather the config

Run the questionnaire from [`demo-spec.md`](../skills/sa-assistant/demo-spec.md#the-questionnaire)
(name, infra default k3d, single/multi-cluster + the other compute, observability default
grafana, API management + portal, AI gateway, MCP gateway). Resolve to a module/chart list
via the [mapping table](../skills/sa-assistant/demo-spec.md#config--module--chart-mapping),
confirm every path against `catalog.json`, and **confirm the list with the user before
writing files.**

Also collect, up front, the **inputs the prospect will need** (Hub token, cloud creds,
domain, any backend keys) so the getting-started guide can name them concretely. Treat
tokens/passwords/keys as `sensitive`.

## Step 2 — Create the repo skeleton

```bash
DEST="${dest:-$HOME/poc-scenarios/<name>}"
mkdir -p "$DEST"
git -C "$DEST" init
```

Lay down the [canonical layout](../skills/sa-assistant/demo-spec.md#canonical-layout) by
adapting the nearest reference demo (the
[golden rule](../skills/sa-assistant/demo-spec.md#golden-rule-copy-the-nearest-reference-demo-dont-generate-from-scratch)
still applies — copy `demos/<seed>/*` into `$DEST` as the starting point), plus a
`.gitignore` (`*.tfvars`, `.terraform/`, `*.tfstate*`, `.kubeconfig`, `.*.kubeconfig`) and
the `GETTING-STARTED.md` from Step 4.

## Step 3 — PIN the library version

This is the one hard difference from `/create-demo`. A PoC is a reproducible artifact handed
to a prospect, so it must **not** depend on this checkout. Resolve the latest release tag:

```bash
TAG=$(git -C <path-to-traefik-demo> describe --tags --abbrev=0)   # e.g. v4.0.0
```

Then rewrite every source to pin that tag:

- **Terraform** — `source = "git::https://github.com/traefik-workshops/traefik-demo.git//terraform/<section>/<path>?ref=<TAG>"`
  (not a relative path, not `?ref=main`).
- **Helm** — `helm install <release> oci://ghcr.io/traefik-workshops/<chart> --version <TAG>`
  (not `./helm/<chart>`).

Pin the third-party providers in `versions.tf` with `~>` as usual. Never pin a PoC to a
moving ref. See [`build-poc/SKILL.md`](../skills/build-poc/SKILL.md) (last rule) and
[`demos/AGENTS.md`](../../demos/AGENTS.md#module-sources-relative-not-pinned) for why
relative-vs-pinned differs between a demo and a PoC.

## Step 4 — Write the hand-holding GETTING-STARTED.md

This is what makes a PoC more than a demo. Write a `GETTING-STARTED.md` that a prospect who
has never seen Traefik Hub can follow start to finish:

```markdown
# <Name> — Traefik Hub PoC

What this proves: <one paragraph, in the prospect's language>.

## Prerequisites
- terraform >= 1.3, kubectl, <k3d | the cloud CLI for the chosen infra>
- A Traefik Hub token (offline JWT) from https://hub.traefik.io
- <any backend keys / cloud creds, named explicitly>

## 1. Configure
cp terraform.tfvars.example terraform.tfvars
# fill in: traefik_hub_token, domain, <the specific vars this build needs>

## 2. Stand it up
make up            # ~N minutes; provisions <infra> + Traefik Hub + <features>

## 3. See it work
make scenarios     # runs the automated <curl|hoppscotch> checks
# then open: <dashboard_url>, <route_url(s)> from `terraform output`

## 4. What to look at
<feature-by-feature tour: where the portal is, how to trigger an AI guard,
 which Grafana dashboard shows the gateway metrics, etc.>

## 5. Tear down
make down

## Troubleshooting
<the 2-3 things most likely to bite: token not set, k3d port in use,
 route still propagating — with the exact fix for each>
```

Tailor every section to the **chosen features** — don't ship a generic template. If the AI
gateway is on, the tour explains the content-guards; if the portal is on, it walks to the
portal URL; etc.

## Step 5 — Test harness + README

- `scenarios.sh` + `Makefile` exactly as in
  [demo-spec Tests](../skills/sa-assistant/demo-spec.md#automated-tests-required) — curl by
  default, hoppscotch when the portal is on. `make up`/`scenarios`/`down`/`fmt`/`validate`.
- A short `README.md` (what it is, link to `GETTING-STARTED.md`) — the detailed walkthrough
  lives in `GETTING-STARTED.md`.
- `terraform.tfvars.example` with placeholders only.

## Step 6 — Validate, commit, hand off

```bash
cd "$DEST"
terraform init -input=false        # fetches the pinned modules from the tag
make fmt
make validate
```

For a k3d PoC, offer to run `make up && make scenarios && make down` end-to-end (needs a Hub
token). Cloud PoCs are validate-only without creds — say so explicitly.

Then commit and discuss the remote with the user (do **not** push without confirmation):

```bash
git -C "$DEST" add .
git -C "$DEST" commit -m "PoC scaffold — <name> (pinned <TAG>)"
```

Ask whether to `gh repo create` + push, or leave it local. Mirror
[`/snapshot-poc`](./snapshot-poc.md)'s discipline: **never commit real secrets** —
`terraform.tfvars` is gitignored; only the `.example` is committed.

## Rules

- **Pinned sources only** — `?ref=<TAG>` / `--version <TAG>`, never relative, never `main`.
  This is the inverse of `/create-demo`.
- **Separate repo** — the PoC does not live under `demos/`; it is its own `git init`'d repo.
- **Hand-holding is the point** — always ship a feature-tailored `GETTING-STARTED.md`.
- **No real secrets committed** — placeholders in `.example`, real values gitignored.
- **Don't invent modules** — only paths in `catalog.json`; pin them at the resolved tag.
- **Don't push without confirmation** — commit locally, then ask.
- If a requested feature has no matching module, say so — don't fabricate one.
