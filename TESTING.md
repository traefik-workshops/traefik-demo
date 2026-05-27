# Testing strategy — terraform-demo-modules

This file is the contract between contributors and CI. It answers three questions:

1. **What is mandatory** to merge a change?
2. **What is opt-in** per module and how to wire it up?
3. **What is deliberately not tested** in this repo and why?

The full per-module recommendations live in the [Coverage matrix](#coverage-matrix). Read that table first if you only have 30 seconds.

---

## Why a tiered policy

This repo's reason for being is "stand up a credible demo fast." Some constraints fall out of that:

- A new module needs to ship the same day it's written. We can't gate on a 30-minute test suite per platform.
- Cloud modules cost real money to apply. A naive "test every module on every PR" matrix would burn hundreds of dollars per week and make small fixes painful.
- Demos pin to immutable tags. A bad release doesn't drift consumers silently — they have to opt in by bumping the tag. That makes regressions noisy and self-limiting.

So the policy is tiered:

| Tier | What runs | When |
|---|---|---|
| **Static** | `terraform fmt -check`, `terraform validate`, `tflint`, `tfsec` | Every PR, every push to `main` |
| **Apply smoke** | Terratest: `init` → `apply` → assert a handful of outputs → `destroy` | Nightly + on PRs that touch the module |
| **Full integration** | Terratest with deployed-resource probing (curl the dashboard, check pod readiness, hit the AI gateway) | Nightly on `main`, opt-in via label on PRs |
| **Skip** | Nothing beyond the static tier | Modules where apply requires hardware we don't have CI credentials for, or where the cost is unjustified |

The default tier for a new module is **Static**. Promote it to **Apply smoke** when you've used it in two demo repos and the variable surface has stopped churning. Promote to **Full integration** when the module is on the critical path of an externally-shown demo.

---

## Mandatory: the static tier

Every module, every PR. No exceptions. CI fails closed if any of these fail:

| Check | Tool | Config | What it catches |
|---|---|---|---|
| Formatting | `terraform fmt -check -recursive` | none | Whitespace, brace style, attribute alignment |
| Syntax + provider schema | `terraform init -backend=false && terraform validate` | per module | Unknown attributes, type mismatches, missing required arguments |
| Convention lint | `tflint --recursive` | [`.tflint.hcl`](./.tflint.hcl) | Missing `description`, missing `type`, non-snake_case names, missing `required_providers`, missing `required_version`, unused declarations, deprecated syntax, unpinned module sources |
| Security lint | `tfsec` | [`.tfsec.yml`](./.tfsec.yml) | Hardcoded credentials, wildcard IAM, public S3, missing TLS — minus the demo-friendly exclusions (single-AZ, public dashboard) |
| Secret scan | `gitleaks` (pre-commit) | upstream defaults | Tokens / keys committed to history |
| Doc drift | `terraform-docs` (pre-commit) | [`.terraform-docs.yml`](./.terraform-docs.yml) | `<!-- BEGIN_TF_DOCS -->` block diverges from `.tf` files |

Running locally:

```bash
make check          # everything above (fmt-check + validate + lint + security)
pre-commit run --all-files   # adds gitleaks + terraform-docs
```

A CI failure on any of these is an immediate "fix and re-push," not a `[skip ci]`.

---

## Opt-in: apply-smoke (terratest)

Apply-smoke is a real `terraform apply` against a real cloud account, kept narrow:

- Smallest valid configuration of the module (minimum required inputs, no extras).
- Asserts that a small, fixed set of outputs is present and non-empty.
- `terraform destroy` runs in a deferred cleanup block — runs even on test failure.

Each tested module gets a sibling `test/` directory:

```
terraform/compute/aws/eks/
├── main.tf
├── variables.tf
├── outputs.tf
├── versions.tf
├── README.md
└── test/
    ├── go.mod
    ├── go.sum
    └── eks_smoke_test.go
```

### Harness pattern

```go
// terraform/compute/aws/eks/test/eks_smoke_test.go
package test

import (
    "testing"
    "time"

    "github.com/gruntwork-io/terratest/modules/terraform"
    "github.com/stretchr/testify/require"
)

func TestEKSSmoke(t *testing.T) {
    t.Parallel()

    tfOpts := &terraform.Options{
        TerraformDir: "..",
        Vars: map[string]interface{}{
            "cluster_name":     uniqueName("smoke"),
            "cluster_location": "us-east-1",
            "eks_version":      "1.30",
        },
        NoColor: true,
    }

    defer terraform.Destroy(t, tfOpts)
    terraform.InitAndApply(t, tfOpts)

    require.NotEmpty(t, terraform.Output(t, tfOpts, "host"))
    require.NotEmpty(t, terraform.Output(t, tfOpts, "cluster_id"))
    require.NotEmpty(t, terraform.OutputRequired(t, tfOpts, "kubeconfig"))
}
```

Conventions for the harness:

- **One `_test.go` per module.** Don't combine modules in one test binary.
- **`t.Parallel()` always.** Tests are independent; serializing wastes wall-clock.
- **Unique names via timestamp+random suffix.** Two parallel runs of the same module against the same account must not collide.
- **`defer terraform.Destroy(...)` immediately after the options block.** Before any assertion. So a panic still cleans up.
- **Assert outputs, not provider internals.** Don't poke at `aws_eks_cluster.this.arn` — go through `terraform.Output`.

### Promotion to full integration

Add deployed-resource probes for modules on the critical demo path:

```go
// Wait for the cluster to be reachable, then check that core kube-system pods are ready.
kubeconfig := terraform.OutputRequired(t, tfOpts, "kubeconfig")
k8sOpts := k8s.NewKubectlOptionsFromKubeconfigString(kubeconfig)
k8s.WaitUntilAllNodesReady(t, k8sOpts, 30, 20*time.Second)
```

For Traefik / AI-gateway modules: `http.Get` the dashboard URL, parse the JSON, assert at least one router is healthy.

### Running locally

```bash
cd terraform/compute/aws/eks/test
go test -timeout 45m -v
```

Requires:

- Go ≥ 1.22
- The cloud's CLI authenticated locally (`aws sts get-caller-identity` etc.)
- For k8s modules: `kubectl` on `PATH`
- For Helm-based modules: `helm` on `PATH`

---

## Cost guardrails

A naive matrix would test every cloud module on every PR. We don't. The rules:

1. **Static tier on every PR.** Free.
2. **Apply-smoke on PR only when the PR touches that module's directory.** A PR to `terraform/compute/aws/eks/` does not spin up GKE.
3. **Apply-smoke nightly on `main` for all promoted modules.** Stable signal without per-PR cost.
4. **Full integration only when labeled.** Add `test:full` to the PR; the workflow picks it up. Reviewer's call.

Per-cloud monthly ceiling (soft cap, alert at 80%):

| Cloud | Cap | Owner |
|---|---|---|
| AWS | $150/mo | SA team account |
| Azure | $100/mo | SA team account |
| GCP | $100/mo | SA team account |
| DigitalOcean | $40/mo | shared SA account |
| Linode | $25/mo | shared SA account |
| Oracle | always-free tier only | shared SA account |
| Nutanix | on-prem lab — no $$ cap, but rate-limit to 1 concurrent apply | lab owner |
| RunPod | $40/mo | shared SA account |

If you're about to add a module that would push a cloud over its cap, talk to the SA team before promoting beyond Static.

---

## Secrets in CI

| Secret | Where | Used by |
|---|---|---|
| `AWS_ROLE_TO_ASSUME` | OIDC, not a long-lived key | apply-smoke on `terraform/compute/aws/*`, `terraform/apps/whoami/ec2,ecs`, `terraform/traefik/ec2,ecs` |
| `AZURE_CREDENTIALS` | OIDC federated | `terraform/compute/azure/*` |
| `GOOGLE_CREDENTIALS` | OIDC federated | `terraform/compute/gcp/*` |
| `DIGITALOCEAN_TOKEN` | repo secret | `terraform/compute/digitalocean/*` |
| `LINODE_TOKEN` | repo secret | `terraform/compute/akamai/*` |
| `OCI_CREDENTIALS` | repo secret | `terraform/compute/oracle/*`, `terraform/security/oci-instance-principal` |
| `RUNPOD_API_KEY` | repo secret | `terraform/compute/runpod/*`, `terraform/ai/LLMs/runpod`, `terraform/ai/NIMs/runpod`, `terraform/ai/granite-guardian/runpod` |
| `NGC_TOKEN`, `NGC_USERNAME` | repo secret | `terraform/ai/NIMs/runpod`, `terraform/compute/runpod/auth` |
| `NUTANIX_*` | self-hosted runner env | `terraform/compute/nutanix/*`, `terraform/apps/whoami/nutanix`, `terraform/traefik/nutanix` |
| `CLOUDFLARE_API_TOKEN` | repo secret | `terraform/tools/cloudflare` |

**Rules:**

- Never read a secret in a static-tier job. Static must run on forks' PRs (no secrets there).
- Always use OIDC over long-lived keys when the cloud supports it (AWS, Azure, GCP do).
- Apply-smoke and full-integration jobs run only on PRs from this repo (not forks). The workflow uses `if: github.event.pull_request.head.repo.full_name == github.repository`.

---

## Coverage matrix

The recommended tier for every module. `Static` = mandatory baseline only. `Apply` = apply-smoke. `Full` = apply-smoke + deployed-resource probes. `Skip` = static-only by design; explanation in the Why column.

### `terraform/ai/`

| Module | Tier | Why |
|---|---|---|
| `terraform/ai/23ai/k8s` | Apply | Stateful — verify the StatefulSet comes up. |
| `terraform/ai/LLMs/runpod` | Skip | RunPod GPU pods cost too much to spin up on every nightly. Manual test before each release. |
| `terraform/ai/NIMs/runpod` | Skip | Same as above + NGC token has rate limits. |
| `terraform/ai/ai-gateway-dependencies/k8s` | Apply | CRDs and namespaces — fast, cheap, high regression value. |
| `terraform/ai/granite-guardian/runpod` | Skip | GPU cost. |
| `terraform/ai/knative/k8s` | Apply | Knative is brittle on version bumps; cheap to install. |
| `terraform/ai/milvus/k8s` | Full | Vector store on the demo critical path. Probe `endpoint` for a tcp connect. |
| `terraform/ai/ollama/k8s` | Apply | Verify Helm release + at least one pod ready. |
| `terraform/ai/open-webui/k8s` | Apply | UI module; deploy + dashboard 200 check. |
| `terraform/ai/presidio/k8s` | Apply | PII analyzer; check service endpoint. |
| `terraform/ai/sqlcl/k8s` | Static | Just a pod with a shell. Apply provides no signal beyond `kubectl get pod`. |
| `terraform/ai/weaviate/k8s` | Full | Same justification as Milvus. |

### `terraform/apps/`

| Module | Tier | Why |
|---|---|---|
| `terraform/apps/httpbin/k8s` | Static | Stub — see STUB-01. Promote to Apply once it has variables. |
| `terraform/apps/whoami/cloud-init` | Static | Template-only module; nothing to apply. |
| `terraform/apps/whoami/ec2` | Apply | EC2 + cloud-init combo; cheap, fast. |
| `terraform/apps/whoami/ecs` | Apply | Fargate spin-up + service-running assertion. |
| `terraform/apps/whoami/k8s` | Full | Used in nearly every Traefik demo; probe the whoami URL. |
| `terraform/apps/whoami/nutanix` | Apply | Self-hosted Nutanix runner; nightly only. |
| `terraform/apps/whoami/nutanix/image_builder` | Skip | Image build takes ~25 min; manual pre-release only. |

### `terraform/compute/`

| Module | Tier | Why |
|---|---|---|
| `terraform/compute/aws/ec2` | Apply | Fast. |
| `terraform/compute/aws/ecs` | Apply | Fargate cluster is cheap. |
| `terraform/compute/aws/eks` | Full | Most-used cluster module. Probe `kubectl get nodes`. |
| `terraform/compute/aws/vpc` | Apply | No running cost; validate outputs. |
| `terraform/compute/azure/aks` | Full | Same as EKS. |
| `terraform/compute/gcp/gke` | Full | Same as EKS. |
| `terraform/compute/digitalocean/doks` | Full | Cheapest hosted k8s — primary CI target for "any k8s." |
| `terraform/compute/akamai/lke` | Apply | LKE is cheap; node-ready check optional. |
| `terraform/compute/oracle/oke` | Apply | Always-free shape; check cluster_id only. |
| `terraform/compute/nutanix/vm` | Apply | Self-hosted runner; nightly. |
| `terraform/compute/nutanix/vpc` | Apply | Same. |
| `terraform/compute/nutanix/subnet` | Apply | Same. |
| `terraform/compute/nutanix/fip` | Apply | Same. |
| `terraform/compute/nutanix/storage_container` | Apply | Same. |
| `terraform/compute/nutanix/categories` | Static | Pure tagging; no apply signal. |
| `terraform/compute/nutanix/nkp` | Full | Multi-resource cluster install; the highest-risk on-prem module. |
| `terraform/compute/nutanix/nkp/kommander` | Apply | Verify Helm release. |
| `terraform/compute/nutanix/nkp/registry` | Apply | VM + ports open. |
| `terraform/compute/nutanix/nkp/bastion_image` | Skip | Packer image build — manual. |
| `terraform/compute/nutanix/nkp/registry_image` | Skip | Packer image build — manual. |
| `terraform/compute/runpod/auth` | Static | One-time credentials setup; apply test would burn the API key's daily quota. |
| `terraform/compute/runpod/pod` | Skip | GPU cost. |
| `terraform/compute/suse/k3d` | Full | Runs entirely on the CI runner; no cloud cost. Probe `kubectl get nodes`. **Use this as the generic "any k8s" target in shared tests.** |

### `terraform/observability/`

| Module | Tier | Why |
|---|---|---|
| `terraform/observability/prometheus/k8s` | Apply | Helm release + at least one target scraped. |
| `terraform/observability/grafana/k8s` | Apply | Dashboard URL reachable. |
| `terraform/observability/grafana/k8s/dashboards/aigateway` | Static | Data-only module. |
| `terraform/observability/grafana-loki/k8s` | Apply | Pods ready + service responds. |
| `terraform/observability/grafana-tempo/k8s` | Apply | Same. |
| `terraform/observability/grafana-stack/k8s` | Full | Umbrella module — most critical for demos that use the stack. |
| `terraform/observability/opentelemetry/k8s` | Apply | Collector receives a test trace. |
| `terraform/observability/langfuse/k8s` | Full | Postgres-backed; verify init user exists. |

### `terraform/security/`

| Module | Tier | Why |
|---|---|---|
| `terraform/security/cognito` | Apply | User-pool create + delete is fast and free. |
| `terraform/security/entraid` | Apply | App registration — same. |
| `terraform/security/keycloak/k8s` | Full | Login flow with seeded user, hit the OIDC discovery endpoint. |
| `terraform/security/oci-instance-principal` | Apply | IAM only; cheap. |

### `terraform/tools/`

| Module | Tier | Why |
|---|---|---|
| `terraform/tools/argocd/k8s` | Apply | UI module; check `/healthz`. |
| `terraform/tools/cert-manager/k8s` | Apply | Issuer ready check. |
| `terraform/tools/cloudflare` | Static | Mutates a live DNS zone — apply tests would pollute. Manual test against a sandbox zone. |
| `terraform/tools/k6-operator/k8s` | Apply | Operator pod ready. |
| `terraform/tools/k6-operator/k8s/loadgen/aigateway` | Skip | Requires a running AI gateway; covered transitively by the gateway demo's own E2E. |
| `terraform/tools/mcp-inspector/k8s` | Apply | UI module; `/` returns 200. |
| `terraform/tools/nginx/k8s` | Apply | Ingress controller; service has an IP. |
| `terraform/tools/postgresql/k8s` | Apply | StatefulSet ready + `psql -c 'select 1'` from a sidecar. |
| `terraform/tools/redis/k8s` | Apply | `redis-cli ping`. |

### `terraform/traefik/`

| Module | Tier | Why |
|---|---|---|
| `terraform/traefik/shared` | Static | Pure logic module; tested transitively by every platform module that consumes it. |
| `terraform/traefik/cloud-init` | Static | Template-only. |
| `terraform/traefik/ec2` | Full | Dashboard URL + at least one router healthy. |
| `terraform/traefik/ecs` | Full | Same. |
| `terraform/traefik/k8s` | Full | Same — the most-consumed Traefik module. |
| `terraform/traefik/nutanix` | Apply | Self-hosted runner; nightly only. |

---

## What is deliberately not tested

A non-exhaustive list, with the reasoning:

- **State backend behavior.** Consumers wire their own backend; this repo never writes state in CI.
- **Cross-cloud upgrades.** `terraform apply` of `v1.4.0` then `terraform apply` of `v1.5.0` would catch upgrade-path regressions but the matrix cost is prohibitive. We rely on consumers reporting drift.
- **Provider beta features.** If a module uses a `_v2` resource that's in upstream beta, we don't test the beta-specific path — too flaky.
- **GPU code paths in RunPod modules.** GPU pods cost $0.50-$3/hr. We test on apply only manually before a release.
- **Cloudflare DNS changes.** Apply tests would mutate real DNS records.
- **Packer image builds.** 25+ minute build, GB-sized artifacts — manual only.
- **The actual demos.** Demos live in their own repos and have their own CI.

---

## Adding a test for an existing module

1. Pick the right tier from the matrix above.
2. Create the `test/` subdirectory next to the module's `.tf` files.
3. Use the [harness pattern](#harness-pattern) — copy the closest sibling test.
4. Add the module to `.github/workflows/apply-smoke.yml` under the appropriate cloud's job.
5. Run locally once with real credentials before pushing.

If your module is `Skip` and you have a reason to promote it, open a PR that:

- Updates the matrix entry above with the new tier
- Adds the test
- Includes a sentence in the PR description about why the cost is now justified

---

## Adding a test for a new module

The `new-module` skill (see [`./.claude/skills/new-module/SKILL.md`](./.claude/skills/new-module/SKILL.md)) prompts for the tier and, if you pick anything above `Static`, scaffolds the `test/` directory and a starter `_test.go`. You still need to fill in the assertions.

---

## CI workflow files

- `.github/workflows/ci.yml` — Static tier (fmt, validate, lint, security). Runs on every PR.
- `.github/workflows/apply-smoke.yml` — Apply tier. Per-cloud jobs; runs on PRs touching that cloud's modules and nightly on `main`.
- `.github/workflows/integration.yml` — Full tier. Nightly on `main`; PR opt-in via `test:full` label.
- `.github/workflows/helm-ci.yml` — Helm static + ct install on kind. See [the helm section below](#helm).
- `.github/workflows/helm-publish.yml` — Helm OCI publish on repo tag push. See helm section below.

If a workflow doesn't exist yet, write it before promoting the first module to that tier. Don't expand the matrix faster than the workflow can support it.

---

## Helm

Helm charts under `helm/` follow the **same tiered model** but with helm-native tooling.

### Tiers

| Tier | What runs | When |
|---|---|---|
| **Static** | `helm lint --strict` (uses `values.schema.json`), `helm template | kubeconform -strict -summary`, `ct lint --target-branch=main` | Every PR |
| **Install** | `ct install --target-branch=main` against a kind cluster (chart-testing creates a temp namespace, installs, runs `helm test`, destroys) | PRs touching a chart, plus nightly on `main` |
| **Integration** | Above + cross-chart smoke tests (install `airlines` umbrella, hit dashboard URLs from the test pod) | Nightly on `main`; PR opt-in via `test:full` label |

Default tier for a new chart is **Static + Install** — kind is free, so we lean on it.

### Mandatory: static tier

| Check | Tool | Catches |
|---|---|---|
| Schema-aware lint | `helm lint --strict` | Missing required values, type mismatches against `values.schema.json`, missing `appVersion`/`maintainers` |
| Rendered-manifest validation | `helm template ... \| kubeconform -strict -summary` | Invalid Kubernetes manifests, deprecated APIs, malformed CRD usage |
| Chart-testing lint | `ct lint --config helm/ct.yaml` | Bumped without version bump (less relevant here — versions are repo-wide), README presence, NOTES.txt presence |
| Doc drift | `helm-docs` (pre-commit) | `<!-- BEGIN_HELM_DOCS -->` block diverges from `Chart.yaml` + `values.yaml` |

Locally:

```bash
make helm-lint     # helm lint --strict for every chart
make helm-template # helm template every chart, pipe to kubeconform
make helm-test     # ct lint --all
```

### Install tier — ct install on kind

```bash
# CI does this on every PR that touches helm/*; you can run it locally:
kind create cluster --name demo-ct
ct install --config helm/ct.yaml --target-branch main
kind delete cluster --name demo-ct
```

ct will:

1. Detect which charts changed (`ct list-changed --target-branch main`).
2. For each, `helm install <chart> --generate-name --create-namespace`.
3. Wait for resources to become ready (kubectl wait, configurable per chart in `ct.yaml`).
4. Run any `templates/tests/*.yaml` Helm tests (pods annotated with `helm.sh/hook: test`).
5. `helm uninstall` and delete the namespace.

### Helm test files

Every chart should ship at least one Helm test under `templates/tests/`:

```yaml
# helm/<chart>/templates/tests/healthz.yaml
apiVersion: v1
kind: Pod
metadata:
  name: "{{ include "<chart>.fullname" . }}-test-healthz"
  annotations:
    "helm.sh/hook": test
    "helm.sh/hook-delete-policy": before-hook-creation,hook-succeeded
spec:
  restartPolicy: Never
  containers:
    - name: healthz
      image: curlimages/curl:8.10.1
      command: ["/bin/sh", "-c"]
      args:
        - |
          curl -fsS http://{{ include "<chart>.fullname" . }}:{{ .Values.service.port }}/healthz
```

### Values-schema validation

Every chart ships `values.schema.json`. The `new-chart` skill generates a starting schema from `values.yaml`; hand-edit to add descriptions and tighten required fields.

`helm lint --strict` enforces the schema on every PR. If a valid value gets rejected, fix the schema, not the value.

### Coverage matrix

| Chart | Tier | Why |
|---|---|---|
| `helm/ai-gateway` | Install | Mid-weight Helm release; depends on presidio + embeddings (+ optionally weaviate). Verify install + at least one `IngressRoute` ready. |
| `helm/airlines` | Integration | Umbrella chart on the demo critical path. Probe a few API URLs from the test pod. |
| `helm/dns-traefiker` | Install | Single Deployment + RBAC; cheap to install. |
| `helm/embeddings` | Install | Stateless Infinity server; install + `/health` check. |
| `helm/hoppscotch` | Install | Frontend + nginx; install + `/` returns 200. |
| `helm/keycloak` | Install | Stateful (postgres) but cheap; install + `helm test` hits `/realms/<realm>/.well-known/openid-configuration`. |
| `helm/presidio` | Install | Single analyzer pod; install + `/health`. |

### Cost guardrails

Charts run on kind in CI — **zero cloud cost**. No per-chart cap.

### Secrets in CI for helm

| Secret | Where | Used by |
|---|---|---|
| `GITHUB_TOKEN` | built-in | `helm push oci://ghcr.io/...` on tag |

No long-lived credentials needed for the static or install tiers. Integration tests that exercise external IdPs (e.g. an `airlines` install hitting a hosted Cognito) would inherit the Terraform-side secret matrix.

### What is deliberately not tested for helm

- **External chart pulls.** `weaviate` is pulled from `https://weaviate.github.io/weaviate-helm` at `helm dep update` time. We don't pin its commit; if upstream breaks, we find out.
- **OCI auth flows from third-party clients.** Demo charts assume `helm registry login` is a solved problem on the consumer's side.
- **Multi-cluster install paths** (`global.multicluster.enabled=true` in airlines). Single-cluster kind can't model this. Test manually on a real two-cluster setup before any release that touches `multicluster.*`.
