# Build PoC

Receive a confirmed scenario, collect inputs, deploy modules in order.

## Invocation

```
/build-poc "<scenario description>"
```

Examples:
```
/build-poc "AWS + Traefik + Ollama + Keycloak for prospect Acme"
/build-poc "Azure AKS demo with Traefik Hub and EntraID SSO for prospect Contoso"
/build-poc "local k3d demo with full observability stack for prospect FooBar"
```

## Step 1 — Parse scenario

From the description, extract:
- **Cloud provider**: AWS / Azure / GCP / Oracle / Nutanix / local (k3d) / RunPod
- **Components**: AI, observability, security/SSO, tools
- **Prospect name**: used for snapshot folder

Confirm every module exists before planning: `find terraform -name versions.tf -not -path '*/.terraform/*' | xargs dirname | sort` (TF) and `find helm -name Chart.yaml -maxdepth 2 | xargs dirname | sort` (Helm). Read each candidate module's `variables.tf` to determine required inputs and `outputs.tf` for credentials/endpoints it will produce.

Deploy order is always:

**Terraform phase (provisioning):**

1. `terraform/compute/<provider>/...` — provisions cluster, outputs kubeconfig (skip if reusing one)
2. `terraform/traefik/...` — Traefik Hub (needs kubeconfig)
3. `terraform/security/...` — identity provider, if SSO requested
4. `terraform/observability/...` — monitoring stack, if requested
5. `terraform/ai/...` — AI workloads, if requested
6. `terraform/tools/...` — postgres/redis/cert-manager/etc., as needed
7. `terraform/apps/...` — sample workloads last

**Helm phase (workloads on top):**

8. `helm/<chart>` — install demo workload charts. Same ordering principle (base deps first):
   - `helm/dns-traefiker` — if the demo needs auto-DNS
   - `helm/keycloak` — if the demo needs an in-cluster IdP (often subchart of `helm/airlines`)
   - `helm/embeddings`, `helm/presidio` — middleware backends for the AI gateway
   - `helm/ai-gateway` — depends on `helm/presidio` + `helm/embeddings` if their middlewares are enabled
   - `helm/hoppscotch` — API testing UI
   - `helm/airlines` — umbrella; pulls keycloak/hoppscotch/ai-gateway as subcharts (install this LAST if used; skip the standalone versions of its subcharts)

Charts under `helm/airlines` and `helm/ai-gateway` are **umbrella charts** — if you install them, you do NOT also install their subcharts standalone. Gate via `enabled: true|false` in `values.yaml`.

## Step 2 — Declare deploy plan

Show SA before touching anything:

```
Deploy plan for prospect: <name>
Cloud: <provider>

Modules (in order):
  1. compute/<provider>/<variant>
  2. traefik/shared
  3. security/<module>       (if SSO requested)
  4. observability/<module>  (if monitoring requested)
  5. ai/<module>             (if AI requested)
  6. tools/<module>          (if tools requested)
  7. apps/<module>

Required credentials:
  - <list what's needed>

Required inputs (no defaults):
  - <list vars that must be provided>
```

Wait for SA confirmation before proceeding.

## Step 3 — Collect inputs

For each module in the plan:
1. Read `variables.tf`
2. Identify vars with no default
3. Ask SA for all missing values — one round, grouped together
4. Do NOT ask for vars that have defaults unless SA wants to override

## Step 4 — Deploy

For each module in plan order:

```bash
cd <module-path>
terraform init -input=false
terraform apply -auto-approve -var="<key>=<value>" ...
```

- Deploy compute first — capture kubeconfig output before next module
- Pass kubeconfig to all subsequent k8s modules via `KUBECONFIG` env var
- If any module fails: stop, report exact error, do NOT continue
- Never run `terraform destroy` — only `apply`
- If KUBECONFIG not set after compute deploy, stop and report

## Step 5 — Helm install (if any helm/ charts in plan)

For each chart in the helm phase:

```bash
helm install <release-name> ./helm/<chart> \
    --create-namespace --namespace <release-name> \
    --set <key>=<value> \
    --wait --timeout=10m
```

- Always `helm dep update ./helm/<chart>` first if the chart has subchart dependencies (ai-gateway, airlines).
- Use `--wait` so subsequent installs see running pods.
- If a chart's `values.schema.json` rejects your values, fix the values, not the schema.
- Pass cluster credentials via `KUBECONFIG` (carried over from the Terraform phase).
- If any chart install fails: stop, report exact error, do NOT continue.

For each chart, read `values.yaml` and the chart's `README.md` to identify which values you need to override. Required values are listed in `values.schema.json` under the `required` array.

## Rules

- Never auto-apply without showing deploy plan first
- Match the prospect's stated cloud preference — do not substitute without asking
- Keep the PoC minimal: only deploy what the scenario requires
