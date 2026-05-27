# terraform-demo-modules — Agent Context

Reusable Terraform modules for Traefik Hub SA demos. Each module is standalone — no inter-module dependencies within this repo. Modules are composed at deploy time by the SA.

## Module structure

Every module follows the same pattern:

```
<category>/<provider>/<variant>/
  main.tf        # resources
  variables.tf   # input vars
  outputs.tf     # outputs
  versions.tf    # required_providers block
```

57 modules across: `ai/`, `compute/`, `observability/`, `security/`, `tools/`, `traefik/`, `apps/`.

## Developer workflow

### Before every commit

```bash
make preflight          # fmt-check + lint — this is the test suite for this repo
```

If it fails, fix it before pushing. CI runs the same checks.

### Adding a test

All checks must be Makefile targets — never run tools directly in CI or documentation. If you add a new check:

1. Add a target to `Makefile`
2. Wire it into `preflight` if it should run on every commit (fast, no cloud creds)
3. Or add a standalone target if it's slow / needs credentials — document it in this file
4. Update `.github/workflows/preflight.yml` if CI should run it

### Auto-fix formatting

```bash
make fmt                # rewrites all .tf files in place — safe, no logic changes
```

### Deep validate a single module

```bash
make validate MODULE=compute/azure/aks   # terraform init + validate, no cloud creds
```

Run this on any module you're about to modify or deploy.

### Adding a new module

Every module must have exactly these four files — no more, no less:

```
<category>/<provider>/<variant>/
  main.tf        # resources
  variables.tf   # input vars (always define type + description + default where safe)
  outputs.tf     # outputs (always output kubeconfig for compute modules)
  versions.tf    # required_providers block (never modify an existing one without SA approval)
```

After creating a new module:
1. `make fmt` — normalize formatting
2. `make validate MODULE=<category>/<provider>/<variant>` — confirm it validates clean
3. `make preflight` — confirm repo-wide checks still pass
4. Update [MODULE_CATALOG.md](MODULE_CATALOG.md) — credential table + category reference

### What the checks catch

| Check | Command | Finds |
|---|---|---|
| Format | `make fmt-check` | Whitespace/indentation drift |
| Lint | `make lint` | Invalid cloud values, deprecated args |
| Validate | `make validate MODULE=<path>` | Syntax errors, bad references, unknown resource types |

## Module catalog

Full catalog in [MODULE_CATALOG.md](MODULE_CATALOG.md) — credential requirements, deploy order, full category reference.

When you need module details (selecting modules for a scenario, checking credentials, deploy order), read MODULE_CATALOG.md before answering.

## SA assistant

Activate with `/sa-assistant`. The skill handles intake → scenario → preflight → deploy → snapshot end-to-end. See [`.claude/skills/sa-assistant.md`](.claude/skills/sa-assistant.md).
