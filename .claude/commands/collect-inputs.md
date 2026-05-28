# Collect Inputs

Interactive loop with the SA to gather every module input (credentials, kubeconfig, tokens, config values) required before deployment. Loops until all required inputs are satisfied.

## Invocation

```
/collect-inputs
/collect-inputs <path-to-poc.yaml>
```

With no argument: reads `poc.yaml` from the current working directory.

## Step 1 — Load required inputs

Read `feasibility.required_inputs` from `poc.yaml`. This is the authoritative list produced by `/feasibility-check` — one entry per module, each with var names, types, and descriptions.

If `feasibility` section is missing: stop and ask SA to run `/feasibility-check` first.

## Step 2 — Present checklist

Print the full input checklist grouped by module:

```
Inputs required for: <prospect name>

terraform/compute/aws/eks
  □ cluster_name  (string)   EKS cluster name

terraform/security/cognito
  □ pool_id       (string)   Cognito user pool ID
  □ client_id     (string)   Cognito app client ID

terraform/observability/grafana-stack/k8s
  □ namespace     (string)   Namespace to deploy Grafana stack into
  □ dashboards    (list)     Dashboard config — see module README

Total: <N> inputs across <M> modules
```

## Step 3 — Gather inputs interactively

Ask SA to provide values one module at a time. For each var:

- If SA provides a value → mark ✅, record it.
- If SA says "I'll get this later" → mark ⏳, continue.
- If SA doesn't know → explain what the var is for, suggest how to find it (e.g., "pool_id: find in AWS Console → Cognito → User Pools").
- Never accept a blank value for a required input — ask again or mark ⏳.

Sensitive vars (`*_password`, `*_token`, `*_key`, `*_secret`, `kubeconfig`) — accept but flag as sensitive; they will be redacted in snapshot.

## Step 4 — Loop until complete

After collecting all available inputs, show remaining ⏳ items. If any remain:

```
Still needed:
  ⏳ terraform/security/cognito → pool_id
  ⏳ terraform/security/cognito → client_id

Options:
  1. Provide them now
  2. Continue when ready (re-run /collect-inputs to resume)
```

Do not proceed to deployment until `inputs.status: complete`.

## Step 5 — Append to poc.yaml

```yaml
inputs:
  status: complete           # complete | pending
  vars:
    - { module: terraform/compute/aws/eks,  var: cluster_name, value: "nexovault-demo",  sensitive: false }
    - { module: terraform/security/cognito, var: pool_id,       value: "us-east-1_AbCd", sensitive: true  }
    - { module: terraform/security/cognito, var: client_id,     value: "1a2b3c4d5e",     sensitive: true  }
```

Sensitive values are written as-is to `poc.yaml` (SA's local file). They are redacted in `/snapshot-poc` output.

## Rules

- Never skip a required input silently — mark it ⏳ and surface it.
- Never proceed to `build-poc` while `inputs.status: pending`.
- Do not ask for `optional_inputs` — only what `/feasibility-check` listed as required.
- If an input conflicts with a constraint in `scenario.constraints` (e.g., SA provides a GPU region but constraint says "no GPU"), flag the conflict before accepting.
