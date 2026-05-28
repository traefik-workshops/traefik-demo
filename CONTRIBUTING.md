# Contributing

Quick reference for adding or changing modules. The full conventions live in [`CLAUDE.md`](./CLAUDE.md); this file is the workflow.

## Before you change anything

1. Skim the relevant `<section>/CLAUDE.md` for section-specific rules before changing anything.
2. Skim the section's `README.md` and `CLAUDE.md`.
3. Look at the closest existing module — pattern-match, don't invent.

## Adding a new module

The fast path is the scaffolding skill:

```
@new-module
```

It will ask which section/platform/name and write the canonical file layout (see [`CLAUDE.md`](./CLAUDE.md)). If you scaffold by hand:

```
<section>/<platform>/<module>/
├── main.tf
├── variables.tf
├── outputs.tf
├── versions.tf
└── README.md
```

Then:

1. `make fmt` to format.
2. `make validate` to catch syntax errors.
3. `make lint` to catch convention violations.
4. Add an entry to the section `README.md` if it has a module table.

## Changing an existing module

| Change | Release type |
|---|---|
| Fixing a bug without renaming/removing anything | `release-bug` (patch) |
| Adding a new variable **with a default** | `release-feature` (minor) |
| Adding a new output | `release-feature` (minor) |
| Adding a new module | `release-feature` (minor) |
| Renaming a variable | `release-major` |
| Removing a variable | `release-major` |
| Changing a variable's default value | `release-major` |
| Removing an output | `release-major` |
| Bumping a pinned provider major | `release-major` |

When in doubt, treat as breaking. Downstream demos pin tags — a wrong major-vs-minor call causes silent drift on the next `terraform init`.

## Local checks

```bash
make fmt        # terraform fmt -recursive
make validate   # terraform validate per module
make lint       # tflint per module
make security   # tfsec/trivy security scan
make check      # all of the above
```

CI runs `make check` on PRs.

## Pre-commit (optional but recommended)

```bash
pip install pre-commit
pre-commit install
```

## Releasing

Only maintainers tag releases. From a clean `main`:

```bash
make release-bug      # for fixes
make release-feature  # for additive features
make release-major    # for breaking changes
```

The targets print the diff since the last tag, ask for confirmation, then tag and push.

## Style points

- `snake_case` for variables and outputs.
- `description` on every variable and output. No exceptions.
- `sensitive = true` on every credential, token, password, or kubeconfig.
- Feature toggles are `enable_<thing>` booleans.
- Keep `main.tf` under ~300 lines; split into topic files (`metrics.tf`, `kubeconfig.tf`) when it grows.

## What to commit, what not to

Commit:
- `.tf` files, `README.md`, `CLAUDE.md`, `.tflint.hcl`, `Makefile`, `.github/workflows/`, the skill under `.claude/`.

Do not commit:
- `.terraform/`, `*.tfstate`, `*.tfvars`, `.DS_Store`, anything under `bin/` or `images/`. `.gitignore` covers these.

## Questions

Open an issue or ping the SA team in Slack.
