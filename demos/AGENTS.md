# Agent guide — `demos/`

`demos/` holds **compositions** of the library in this repo. Two tiers:

- **Archetypes** — minimal Terraform-only reference compositions (`single-cluster`,
  `unified-ingress`, `ai-gateway`, `oidc-portal`). They show the *shape* of a
  composition; they aren't meant to be run end-to-end. This is what the
  `build-poc` / `sa-assistant` skill pattern-matches against.
- **Runnable demos** — self-contained, k3d-based, white-labeled demos
  (`hub-from-source`, `ai-gateway-openai`) you can actually bring up locally for
  free. Each ships a `Makefile` + `scenarios.sh`.

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
| Scenarios | `make scenarios` — curl each route, assert status/refusal vs a table | by hand (needs a cluster + any tokens) |

`make validate` is the offline gate (relative sources resolve locally). Live
apply + `make scenarios` is the human-run half — Traefik Hub needs a license
token, and some demos need provider keys, so they can't run secret-free in CI.

## Secrets

Never commit real values. Real inputs go in `terraform.tfvars` (gitignored);
only `terraform.tfvars.example` with placeholders is committed. White-labeled
demos must carry **no** client names, domains, tokens, or sample data — these
are derived from real demos but fully de-branded.
