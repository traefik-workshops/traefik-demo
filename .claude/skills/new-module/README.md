# new-module skill

Scaffolds a new leaf module under `terraform-demo-modules` following the canonical layout in [`/CLAUDE.md`](../../../CLAUDE.md).

Two ways to use it:

## 1. Via Claude / any LLM-driven agent

If the agent is running inside this repo with skill discovery enabled, it loads automatically when the user says anything like "scaffold a new module," "add a module for X," etc. The agent reads [`SKILL.md`](./SKILL.md), gathers section/platform/name/purpose from the user, and runs `scaffold.sh`.

## 2. Directly from the command line

```bash
.claude/skills/new-module/scaffold.sh \
    --section tools \
    --platform k8s \
    --name vault \
    --purpose "HashiCorp Vault for demo secrets"
```

The script:

1. Validates the section is one of the seven supported.
2. Picks a template (`base`, `k8s-helm`, `cluster`, `iaas`, `runpod`, `idp`, `traefik-platform`).
3. Writes `main.tf` / `variables.tf` / `outputs.tf` / `versions.tf` / `README.md` from the template.
4. Runs `terraform fmt` and `terraform validate` on the result.
5. Prints a checklist of what to fill in next.

## Templates

| Template | Used by | Notes |
|---|---|---|
| `base` | template-only / Cloudflare-style modules | Minimal stub |
| `k8s-helm` | every `<section>/k8s/<module>` | Helm wrapper with sensible defaults |
| `cluster` | `compute/<cloud>/<managed-k8s>` | Exposes the five standard cluster outputs |
| `iaas` | `compute/<cloud>/<vm,vpc,subnet,...>`, `apps/whoami/<vm-platform>` | Single-resource shape |
| `runpod` | `ai/<model>/runpod`, `compute/runpod/*` | Null-resource + curl pattern |
| `idp` | `security/<cloud>/<idp>` | `random_password`, seeded users, standard IdP outputs |
| `traefik-platform` | `traefik/<platform>` | Composes from `traefik/shared` |

The picker in `scaffold.sh` chooses automatically based on section + platform + name suffix. Override with `--template <name>` if you need to.

## Editing the templates

If you change the canonical module shape in `/CLAUDE.md`, update the templates here in the same commit. The pre-commit `terraform_docs` hook applies the doc convention to generated modules, but it can't fix structural drift.
