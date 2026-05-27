# terraform-demo-modules

Reusable Terraform modules for provisioning Traefik Hub demo environments across multiple cloud providers and Kubernetes distributions.

## Module catalog

```
ai/            AI/ML workloads (Ollama, NVIDIA NIMs, Milvus, Weaviate, Open WebUI, Presidio…)
compute/       Kubernetes clusters (EKS, AKS, GKE, OKE, DOKS, LKE, NKP, K3d) + VMs
observability/ Grafana stack, Prometheus, Loki, Tempo, Langfuse, OpenTelemetry
security/      Identity providers (Keycloak, Cognito, EntraID, OCI Instance Principal)
tools/         Utilities (ArgoCD, cert-manager, Cloudflare, k6, PostgreSQL, Redis…)
traefik/       Traefik Hub deployment (EC2, ECS, Kubernetes, Nutanix)
apps/          Sample workloads (whoami, httpbin)
```

## Validation

Three ways to run the same checks — pick what fits your context.

### CLI (local, before deploying)

```bash
make fmt-check          # check terraform formatting across all modules
make fmt                # auto-fix formatting
make lint               # tflint: catch invalid cloud values, deprecated args
make preflight          # fmt-check + lint combined
make validate MODULE=compute/azure/aks   # deep validate one module (requires terraform init)
```

`make preflight` is the recommended command before any cloud deploy. It runs without cloud credentials and completes in seconds.

`make validate` runs `terraform init -backend=false` + `terraform validate` on a single module. Use it on modules you are about to deploy.

### GitHub Actions (CI, on push/PR)

Runs automatically on every push or PR that touches a `.tf` file:

```bash
make preflight   # fmt-check + lint
```

See [`.github/workflows/preflight.yml`](.github/workflows/preflight.yml).

### Agent (Claude Code)

Open this repo in Claude Code and run `/preflight` or ask "validate compute/azure/aks". The agent calls the same Makefile targets, reads the output, and explains any failures in plain language.

See [`.claude/skills/preflight.md`](.claude/skills/preflight.md) for agent behavior rules.

## What each check catches

| Check | Tool | Needs cloud creds | What it finds |
|---|---|---|---|
| Format | `terraform fmt -check` | No | Whitespace/indentation drift |
| Lint | `tflint` | No | Invalid values, deprecated args, missing tags |
| Validate | `terraform validate` | No (init only) | Syntax errors, wrong resource types, bad references |
| Plan | `terraform plan` | Yes | Real-world apply errors — run manually |

## Contributing

### Adding a module

Every module must have exactly these four files:

```
<category>/<provider>/<variant>/
  main.tf        # resources
  variables.tf   # input vars (type + description + default where safe)
  outputs.tf     # outputs (compute modules must output kubeconfig)
  versions.tf    # required_providers block
```

After adding a module:

```bash
make fmt                                         # normalize formatting
make validate MODULE=<category>/<provider>/<variant>   # confirm clean validate
make preflight                                   # confirm repo-wide checks pass
```

Update the module catalog in CLAUDE.md (credential table + category reference + scenario mapping).

### Pre-commit checklist

```bash
make preflight   # must pass — same checks CI runs
```

## Releasing

```bash
make bump_patch   # or bump_minor / bump_major
make release      # push git tag
```
