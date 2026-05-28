---
name: new-module
description: Scaffold a new Terraform module under the traefik-demo repo following the canonical layout. Use when the user asks to "add a module," "create a module," "scaffold a module," "new module for X," or similar phrases that imply creating a new leaf module in this repo. Picks the right template based on section/platform (k8s-helm, cluster, iaas, traefik-platform, runpod, idp, base).
---

# new-module skill

You are scaffolding a new leaf module under `traefik-demo`. The goal is a module that conforms to the conventions in [`/CLAUDE.md`](../../../CLAUDE.md) on first commit — no follow-up lint fixups required.

## Gather requirements first

Before invoking the scaffold script, use the AskUserQuestion tool to gather:

1. **Section** — one of: `ai`, `apps`, `compute`, `observability`, `security`, `tools`, `traefik`. If the user named anything outside this list, push back: this repo only has seven.
2. **Platform** — usually one of: `k8s`, `aws`, `azure`, `gcp`, `digitalocean`, `akamai`, `oracle`, `nutanix`, `runpod`, `suse`, `cloud-init`, `ec2`, `ecs`. Required for most sections; not used for `traefik` (the platform *is* the module name there) or cloud-native security IdPs (`cognito`, `entraid`).
3. **Name** — the module's directory name. Kebab-case for multi-word (`grafana-loki`, `mcp-inspector`). Validate it doesn't already exist at the target path.
4. **One-line purpose** — written to the module README, used in the section table.

If the user is adding a *variant* of an existing module (e.g. another Ollama model, another Postgres flavor), stop and remind them: model variants are `enable_<variant>` flags on the existing module, not new modules. Only proceed if they confirm it's a genuinely new system.

## Path layout (varies by section — this is intentional)

| Section | Layout | Example |
|---|---|---|
| `ai` | `ai/<name>/<platform>` | `ai/milvus/k8s` |
| `apps` | `apps/<name>/<platform>` | `apps/whoami/ec2` |
| `compute` | `compute/<cloud>/<name>` | `compute/aws/eks` — note: cloud first! |
| `observability` | `observability/<name>/<platform>` | `observability/grafana/k8s` |
| `security` | `security/<name>/<platform?>` | `security/cognito` (no platform) or `security/keycloak/k8s` |
| `tools` | `tools/<name>/<platform>` | `tools/argocd/k8s` |
| `traefik` | `traefik/<platform>` | `traefik/k8s` — no name layer |

The scaffold script computes the right path for you given `--section`, `--platform`, `--name`. Pass them correctly and it works; the script also refuses to scaffold under `traefik/shared` or `traefik/cloud-init` (those are library modules).

## Template picker

| Section | Platform | Template | Why |
|---|---|---|---|
| `ai` | `k8s` | `k8s-helm` | Helm chart wrapper |
| `ai` | `runpod` | `runpod` | RunPod GraphQL via `null_resource`+`curl` |
| `apps` | `k8s` | `k8s-helm` | Helm-installed sample |
| `apps` | `cloud-init` | `base` | Template-only, no resources |
| `apps` | `ec2` / `ecs` / `nutanix` | `iaas` | Provisions VM-like infra |
| `compute` | any cloud | `cluster` if name ends in `ks`/`oke`/`gke`/`aks`/`eks`/`doks`/`lke`/`nkp`/`k3d`, else `iaas` | Managed-k8s vs raw IaaS |
| `compute` | `runpod` | `runpod` | RunPod variant |
| `observability` | `k8s` | `k8s-helm` | Always |
| `security` | `k8s` | `k8s-helm` | Keycloak-style in-cluster IdP |
| `security` | `aws` / `azure` / `oracle` (no `--platform`) | `idp` | Cloud-native IdP provisioning |
| `tools` | `k8s` | `k8s-helm` | Always |
| `tools` | other | `base` | Rare; e.g. Cloudflare DNS |
| `traefik` | any | `traefik-platform` | Composes from `traefik/shared` |

Don't override by hand. If the picker is wrong for your case, fix the picker.

## Invoking the script

```
.claude/skills/new-module/scaffold.sh \
    --section <section> \
    [--platform <platform>] \
    [--name <name>] \
    --purpose "<one-line>" \
    [--template <override>]
```

The script:

1. Computes the target path per the layout above.
2. Refuses to run if the target already exists.
3. Picks a template via the matrix above (override with `--template`).
4. Copies template files, substituting `{{NAME}}` / `{{NAME_HUMAN}}` / `{{PURPOSE}}` / `{{SECTION}}` / `{{PLATFORM}}`.
5. Runs `terraform fmt` on the new directory.
6. Runs `terraform init -backend=false` + `terraform validate` to confirm the generated module parses.
7. Prints the next-steps checklist.

If `terraform` isn't on PATH, the script still scaffolds — it warns and skips validate.

## After scaffolding — what you still do

1. **Add a row to the section's README module table.** Open `<section>/README.md`, find the `| Path | ... |` table, add a row, preserve alphabetical ordering.
2. **Wire the canonical outputs.** Cluster modules need the standard five (`host`, `cluster_ca_certificate`, `token`, `kubeconfig`, `cluster_id`). IdP modules need `user_pool_id`, `app_client_id`, `app_client_secret`, `users`. The template ships placeholders; you wire them to real resources.
3. **Pick a test tier from [`/TESTING.md`](../../../TESTING.md).** Default is `Static`. If on the demo critical path, suggest `Apply`.
4. **Run `make check`** before handing back. Fix the generated code if anything fails; don't disable the lint rule.
5. **Tell the user what they should fill in next.** The placeholders in generated `.tf` files are tagged `# TODO(new-module):`. Don't leave them; either fill them in or flag clearly.

## Don't

- Don't scaffold without asking the four questions. Defaults are deliberately wrong so the skill doesn't run on autopilot.
- Don't write outside the scaffolded module directory (and the one-line addition to the section README).
- Don't bump the repo version. New module = `release-feature` (minor) but the maintainer tags, not the skill.
- Don't pin provider versions to whatever's newest. Match the version already used in sibling modules. The script grep-checks siblings to surface the right version constraints.
- Don't add a new provider without warning the user explicitly. The repo deliberately keeps the provider count low.

## When to refuse

- Section isn't one of the seven.
- Module already exists at the target path.
- User asked for a variant of an existing module (extend the existing one instead).
- User asked for something that's not a Terraform module (a script, docs, workflow).
- User asked for a module under `traefik/shared` or `traefik/cloud-init` — those are library modules; don't fragment them.
