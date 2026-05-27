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

Read MODULE_CATALOG.md to confirm module selection and deploy order.

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

## Rules

- Never auto-apply without showing deploy plan first
- Match the prospect's stated cloud preference — do not substitute without asking
- Keep the PoC minimal: only deploy what the scenario requires
