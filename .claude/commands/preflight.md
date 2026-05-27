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
for module in $(find . -name "versions.tf" | xargs -I{} dirname {} | sed 's|^\./||' | sort); do
  make validate MODULE=$module
done
```

Warn SA this will take several minutes across 57 modules before running.

## Output format

```
── Tier 1: make preflight ─────────────────────────────
✅ fmt-check passed
✅ tflint passed

── Tier 2: make validate ──────────────────────────────
compute/azure/aks      ✅ valid
compute/aws/eks        ✅ valid
ai/ollama/k8s          ❌ Error: unsupported argument
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
