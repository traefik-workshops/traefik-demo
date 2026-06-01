# Agent guide — `demos/`

`demos/` holds runnable, white-labeled **compositions** of the library in this
repo. Four run end-to-end on k3d for free — `single-cluster`, `k3d-unified-ingress`,
`ai-gateway-openai`, `hub-from-source` — each shipping a `Makefile` +
`scenarios.sh` and deployed in CI. One targets a cloud — `oidc-portal` (EKS +
Cognito) — and is `terraform validate`-only in CI, run by hand against AWS. All
of them double as the reference shapes the `build-poc` / `sa-assistant` skill
pattern-matches against.

## Module sources: relative, not pinned

Demos reference the library with **relative paths**:

```hcl
module "traefik" {
  source = "../../terraform/traefik/k8s"   # NOT git::...?ref=<tag>
}
```

Why: a demo lives *inside* the library, so a relative source always matches the
code in this checkout. `terraform validate` runs offline (no GitHub fetch, no
tag dependency) and `terraform apply` always exercises the current modules —
exactly what we want for catching interface drift in CI.

This is the **opposite** of what the `build-poc` skill emits. A generated PoC is
a standalone repo handed to a prospect, so it **pins** `?ref=<version>` for
reproducibility. Relative here, pinned there — same library, different audience.

## Runnable demo layout

```
demos/<name>/
├── versions.tf              # required_providers (incl. k3d for local demos)
├── main.tf                  # the composition — relative module sources
├── variables.tf
├── outputs.tf
├── terraform.tfvars.example # placeholders only — never a real value
├── Makefile                 # up / down / scenarios / fmt / validate (+ demo extras)
├── scenarios.sh             # curl assertions vs an expected table
└── README.md                # what it proves, prereqs, run steps, secrets note
```

## Testing convention

Demos do **not** use the module/chart CI (tflint/tfsec/ct). Theirs is:

| Tier | What | Where |
|---|---|---|
| Static | `terraform fmt -check` + `terraform validate` per demo | CI, every PR — no cloud, no secrets |
| Scenarios | `make scenarios` — curl each route, assert status/refusal vs a table | CI for the four k3d demos (`demos-ci.yml`, gated on `TRAEFIK_HUB_TOKEN`); by hand for `oidc-portal` (needs AWS) |

`make validate` is the offline gate (relative sources resolve locally). The k3d
demos additionally deploy on a real cluster and run `make scenarios` in CI — the
`TRAEFIK_HUB_TOKEN` secret supplies the Hub license (offline mode), so a fork or
Dependabot PR without the secret skips the deploy job cleanly. `oidc-portal`
needs AWS, so its apply + scenarios stay human-run.

## Secrets

Never commit real values. Real inputs go in `terraform.tfvars` (gitignored);
only `terraform.tfvars.example` with placeholders is committed. White-labeled
demos must carry **no** client names, domains, tokens, or sample data — these
are derived from real demos but fully de-branded.
