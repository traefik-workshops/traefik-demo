# Feasibility Check

Answer one question: **can this PoC be built with the modules available in this repo?**

Reads signals from `poc.yaml`, maps them to catalog modules, checks each mapping for viability, and produces the definitive module list plus a required inputs inventory.

## Invocation

```
/feasibility-check
/feasibility-check <path-to-poc.yaml>
```

With no argument: reads `poc.yaml` from the current working directory.

## Step 1 — Load signals

Read the `scenario.signals` list from `poc.yaml`. Each signal has a canonical value and one or more sources.

## Step 2 — Map signals to modules

Read [`catalog.json`](../../catalog.json). For each signal, find catalog entries whose `keywords` contain the signal as a substring (case-insensitive).

When querying `catalog.json` in a shell command, prefer `jq` over `python3 -c`:

```bash
# preferred — works for any signal; pass each signal value as $sig
jq -r --arg sig "cognito" '
  (.modules[], .charts[]) | select(.keywords[]? | ascii_downcase | contains($sig)) | .path
' catalog.json

# fallback when jq unavailable
python3 -c "
import json; sig='cognito'; data=json.load(open('catalog.json'))
for m in data.get('modules',[]) + data.get('charts',[]):
    if any(sig in k.lower() for k in m.get('keywords',[])):
        print(m['path'])
"
```

Rank matches by:
1. Number of distinct keyword matches.
2. Tie-break by section priority: `compute` > `traefik` > `security` > `observability` > `ai` > `tools` > `apps`.

Selection rules:
- **Always include `terraform/traefik/shared`** — required for every PoC.
- **Cloud is mutually exclusive** — pick one compute module matching `scenario.cloud`.
- **CPU vs GPU LLMs** — `terraform/ai/ollama/k8s` is CPU; `terraform/ai/LLMs/runpod` is GPU. Default to CPU unless signals include `gpu`, `runpod`, or model size > 8B.
- **Umbrella charts win over their parts** — if `helm/airlines` matches, do NOT also select `helm/keycloak`, `helm/hoppscotch`, `helm/ai-gateway` standalone.
- **Unmatched signals** — note them as gaps; do not invent a module.

## Step 3 — Check viability

For each selected module, verify:

| Check | Pass | Fail |
|---|---|---|
| Path exists in catalog | ✅ covered | ⚠️ gap — module not in catalog |
| Platform matches `scenario.cloud` | ✅ | 🔀 platform mismatch — list available platforms |

## Step 4 — Build required inputs inventory

For each selected module, read `required_inputs` from `catalog.json` (vars with no default — SA must provide). Group by module. This list feeds `/collect-inputs`.

## Step 5 — Report and confirm

Print feasibility report to chat:

```
Feasibility report for: <prospect name>

✅ Covered:
  terraform/compute/aws/eks        — aws + kubernetes signals
  terraform/traefik/shared         — always included
  terraform/security/cognito       — cognito signal
  helm/airlines                    — airlines signal

🔀 Platform mismatch:
  - <signal>  →  requested azure, available: k8s, aws
                  Closest: <module path>

⚠️ Gaps (no matching module):
  - <signal>  →  <explanation>

Required inputs:
  terraform/compute/aws/eks
    cluster_name  (string)  EKS cluster name
  terraform/security/cognito
    pool_id       (string)  Cognito user pool ID
    client_id     (string)  Cognito app client ID

Verdict: <"Feasible — confirm to save"> or <"Blocked — N gaps must be resolved">
```

Wait for SA confirmation before writing.

## Step 6 — Append to poc.yaml

On SA confirmation:

```yaml
feasibility:
  verdict: feasible          # feasible | blocked
  modules:
    - { path: terraform/compute/aws/eks,             reason: "aws + kubernetes signals" }
    - { path: terraform/traefik/shared,               reason: "always included" }
    - { path: terraform/security/cognito,             reason: "cognito signal" }
    - { path: terraform/observability/grafana-stack/k8s, reason: "grafana signal" }
  charts:
    - { path: helm/airlines, reason: "airlines signal" }
  required_inputs:
    - module: terraform/compute/aws/eks
      vars:
        - { name: cluster_name, type: string, description: "EKS cluster name" }
    - module: terraform/security/cognito
      vars:
        - { name: pool_id,   type: string, description: "Cognito user pool ID" }
        - { name: client_id, type: string, description: "Cognito app client ID" }
  gaps: []
```

## Rules

- Never flag missing credentials — that is `/collect-inputs` scope.
- Never invent a module — only reference paths in `catalog.json`.
- If `catalog.json` looks stale, suggest `make catalog` before re-checking.
- If verdict is `blocked`, stop — do not proceed to preflight until SA resolves gaps.
