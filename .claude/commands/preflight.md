# Preflight

Run before any cloud deploy to catch broken modules early. Always use `make` targets — they are the source of truth for what CI runs.

## Tier 1 — Format + lint (always run, no cloud creds needed)

```bash
make preflight
```

Runs `make fmt-check` (formatting) then `make lint` (tflint) across all modules. Completes in seconds.

If formatting issues found:
- List the affected files
- Ask SA: "Auto-fix formatting? (y/n)"
- If yes: run `make fmt`
- If no: report and continue to lint

If lint fails:
- Report exact tflint output (file + line + rule)
- Do NOT auto-fix — lint errors are logic/config problems
- Wait for SA to decide

## Tier 2 — Validate (only modules about to be deployed)

`terraform init` is slow per-module — only run on modules in the deploy plan.

```bash
make validate MODULE=<path>
```

If SA says "validate all":

```bash
make validate
```

(With no `MODULE=`, the Makefile iterates every leaf module — `terraform init -backend=false` + `terraform validate` per module. This takes several minutes across the ~69 leaf modules. Warn SA before running.)

## Output format

```
── Tier 1: make preflight ─────────────────────────────
✅ fmt-check passed
✅ tflint passed

── Tier 2: make validate ──────────────────────────────
terraform/compute/azure/aks      ✅ valid
terraform/compute/aws/eks        ✅ valid
terraform/ai/ollama/k8s          ❌ Error: unsupported argument
                          on main.tf line 12: An argument named "replicas"
                          is not expected here.
```

## Rules

**May fix automatically:**
- Formatting only — `make fmt` when SA confirms. Whitespace/indentation only, never logic.

**Must never fix automatically:**
- Lint errors — report file + line + rule, let SA decide
- Validate errors — report exact error + file:line, let SA decide
- Missing `versions.tf` — flag it, do not create it (provider version is architecture decision)
- Never run `terraform plan` or `terraform apply` without SA confirmation

**Must always report:**
- Any module where `make validate` exits non-zero
- Any module missing `versions.tf`
- Files failing `make fmt-check`

**Skip:** `.terraform/` directories

## On broken modules — escalate, do not fix

If preflight finds a broken module (lint error, validate error, missing `versions.tf`):

1. **Stop.** Do not continue to deployment.
2. **Report clearly:** exact error, file, line.
3. **Escalate to dev context:**

```
⛔ Module terraform/<path> failed preflight.

This requires a code fix outside SA scope.
Open a new session without sa-assistant loaded and use the dev skills:
  - new-module skill — if the module needs to be rebuilt
  - contributing guide — CONTRIBUTING.md

Do not attempt to fix Terraform code in an SA session.
```

4. Wait for SA to confirm the module is fixed and re-run preflight before proceeding.
