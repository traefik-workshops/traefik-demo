---
name: build-poc
description: Render Terraform and Helm manifests for a confirmed PoC, then optionally deploy to cloud. Reads poc.yaml (all prior steps must be complete). Use when SA says "deploy", "build the PoC", "render manifests", or after /collect-inputs completes.
---

# build-poc skill

You are rendering and optionally deploying a Traefik Hub PoC. All prior steps are complete: intake → scenario → feasibility → preflight → inputs. Your job is to generate deployment-ready files and let the SA decide whether to deploy immediately or review first.

## Prerequisites — verify before acting

Read `poc.yaml` and confirm all sections are present and valid:

| Section | Required state |
|---|---|
| `feasibility.verdict` | `feasible` |
| `preflight.status` | `passed` |
| `inputs.status` | `complete` |

If any check fails: stop, report which section is missing or invalid, wait for SA to fix it.

## Step 1 — Build deploy order

From `feasibility.modules` and `feasibility.charts`, determine execution order:

**Terraform phase (in order):**
1. `compute` — provisions cluster, outputs kubeconfig
2. `traefik` — needs kubeconfig
3. `security` — needs kubeconfig
4. `observability` — needs kubeconfig
5. `ai` — needs kubeconfig
6. `tools` — needs kubeconfig
7. `apps` — needs kubeconfig

**Helm phase** — after all Terraform modules succeed:
8. `helm/dns-traefiker` first (if present — DNS must resolve before ingresses)
9. Dependency charts next (`helm/embeddings`, `helm/presidio`)
10. Umbrella charts last (`helm/ai-gateway`, `helm/airlines`)

**Umbrella rule:** if an umbrella chart is present, skip its standalone subcharts — they're bundled. Gate sub-features via `enabled: true|false` in `values.yaml`.

## Step 2 — Render manifests

For each Terraform module, generate the `terraform apply` invocation with all vars from `inputs.vars`. Write rendered calls to:

```
~/poc-scenarios/<slug>/manifests/terraform/<module-name>.sh
```

For each Helm chart, generate the `helm install` invocation with all values. Write to:

```
~/poc-scenarios/<slug>/manifests/helm/<chart-name>.sh
```

Show SA the rendered manifests before any deployment.

## Step 3 — Ask SA: render-only or deploy?

```
Manifests rendered at: ~/poc-scenarios/<slug>/manifests/

Options:
  1. Deploy now — run all manifests in order
  2. Review first — I'll tell you when to proceed
  3. Render only — save manifests, do not deploy
```

Wait for SA choice.

## Step 4 — Deploy (if SA chose deploy)

Execute manifests in order from Step 1:

```bash
# Terraform
cd <module-path>
terraform init -input=false
terraform apply -auto-approve -var="<key>=<value>" ...
```

- After compute module: capture kubeconfig output, set `KUBECONFIG` env var for all subsequent modules.
- If any module fails: stop immediately, report exact error, do NOT continue.
- Never run `terraform destroy`.

```bash
# Helm
helm dep update ./helm/<chart>
helm install <release-name> ./helm/<chart> \
    --create-namespace --namespace <release-name> \
    --set <key>=<value> \
    --wait --timeout=10m
```

- Read `values.yaml` and `values.schema.json` before setting values.
- If chart install fails: stop, report exact error, wait for SA.

## Step 5 — Append to poc.yaml

```yaml
deployment:
  status: rendered           # rendered | deployed | failed
  manifests_path: ~/poc-scenarios/<slug>/manifests/
  deployed: false            # true if SA chose to deploy
  notes: "<SA choice and any relevant context>"
```

## Rules

- Never deploy without showing manifests first and getting explicit SA confirmation.
- Never substitute a module or chart not in `feasibility.modules` / `feasibility.charts`.
- On any failure: stop immediately, report exact error output, wait for SA input.
- Never run `terraform destroy`.
- Sensitive vars from `inputs.vars` are passed as `-var` flags — never written to `.tfvars` files.
- **Pin the library version.** A PoC is a standalone artifact handed to a prospect, so it must be reproducible. Reference every traefik-demo module and chart at a pinned release tag — `source = "git::https://github.com/traefik-workshops/traefik-demo.git//terraform/<path>?ref=<tag>"` and `helm ... --version <tag>` — where `<tag>` is the repo's latest `v*` release tag (e.g. `git -C <traefik-demo> describe --tags --abbrev=0`). Never pin a PoC to a moving ref (`main`) or a relative path: that is the **demos/** convention (which tracks the live library — see [`demos/AGENTS.md`](../../../demos/AGENTS.md)), not the PoC convention.
