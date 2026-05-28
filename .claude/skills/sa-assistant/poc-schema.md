# PoC Schema — poc.yaml

`poc.yaml` is the progressive build record for a prospect PoC. Each command in the SA workflow appends its own section. The file is the single source of truth — all subsequent commands read from it.

**Location:** `~/poc-scenarios/<prospect-slug>/poc.yaml`

Commands that consume this file must read only their relevant prior sections. Commands that write must append — never overwrite existing sections.

---

## Full schema

```yaml
# ── /intake ───────────────────────────────────────────────────────────────────
intake:
  prospect_slug: string                  # kebab-case company name
  sources:
    - path: string                       # original file path
      type: string                       # email-thread | transcript | slack | pdf | mixed
  normalized_path: string                # path to intake/normalized.md
  contradictions:
    - fact: string
      sources: [string]                  # ["email says X", "call notes say Y"]
      resolved: string                   # which won and why

# ── /extract-scenario ─────────────────────────────────────────────────────────
scenario:
  prospect_name: string                  # required
  industry: string                       # financial services | healthcare | retail | ...
  cloud: string                          # aws | azure | gcp | oracle | nutanix | runpod | local
  constraints: [string]                  # "no GPU", "HIPAA", "EU data residency", ...
  timeline: string                       # "end of May", "Q3", ...
  signals:
    - value: string                      # canonical lowercase signal
      sources: [string]                  # email-thread | call-notes | slack | direct
  unmatched: [string]                    # signals with no keyword hit in catalog
  questions: [string]                    # open questions SA must resolve

# ── /feasibility-check ────────────────────────────────────────────────────────
feasibility:
  verdict: string                        # feasible | blocked
  modules:
    - path: string                       # terraform/<section>/<platform>/<name>
      reason: string
  charts:
    - path: string                       # helm/<name>
      reason: string
  required_inputs:
    - module: string
      vars:
        - name: string
          type: string
          description: string
  gaps:
    - signal: string
      explanation: string

# ── /preflight ────────────────────────────────────────────────────────────────
preflight:
  status: string                         # passed | failed
  checks:
    - module: string
      fmt: string                        # ok | fail
      validate: string                   # ok | fail
      error: string                      # present only on fail

# ── /collect-inputs ───────────────────────────────────────────────────────────
inputs:
  status: string                         # complete | pending
  vars:
    - module: string
      var: string
      value: string
      sensitive: boolean                 # true for tokens, passwords, kubeconfig

# ── build-poc skill ───────────────────────────────────────────────────────────
deployment:
  status: string                         # rendered | deployed | failed
  manifests_path: string                 # ~/poc-scenarios/<slug>/manifests/
  deployed: boolean
  notes: string

# ── /snapshot-poc ─────────────────────────────────────────────────────────────
snapshot:
  timestamp: string                      # ISO-8601
  status: string                         # pushed | local-only
  repo: string                           # git repo URL or ""
  demo_md: string                        # path to DEMO.md
  sensitive_values: string               # always "redacted"
```

---

## Example — NexoVault Financial (AWS, API management)

```yaml
intake:
  prospect_slug: nexovault-financial
  sources:
    - { path: fixtures/example-1/transcript.md, type: mixed }
  normalized_path: ~/poc-scenarios/nexovault-financial/intake/normalized.md
  contradictions: []

scenario:
  prospect_name: NexoVault Financial
  industry: financial services
  cloud: aws
  constraints:
    - "no GPU"
    - "must use existing Cognito pool"
    - "SOC 2 — audit-grade API access logs"
  timeline: "end of May"
  signals:
    - { value: aws,        sources: [email-thread] }
    - { value: cognito,    sources: [email-thread] }
    - { value: kubernetes, sources: [call-notes] }
    - { value: grafana,    sources: [call-notes] }
    - { value: airlines,   sources: [call-notes] }
  unmatched: []
  questions:
    - "Cognito pool ID and client ID — SA to collect"

feasibility:
  verdict: feasible
  modules:
    - { path: terraform/compute/aws/eks,                 reason: "aws + kubernetes signals" }
    - { path: terraform/traefik/shared,                   reason: "always included" }
    - { path: terraform/traefik/k8s,                      reason: "Traefik Hub on k8s" }
    - { path: terraform/security/cognito,                 reason: "cognito signal" }
    - { path: terraform/observability/grafana-stack/k8s,  reason: "grafana signal" }
  charts:
    - { path: helm/airlines, reason: "airlines signal — full API portal demo" }
  required_inputs:
    - module: terraform/compute/aws/eks
      vars:
        - { name: cluster_name, type: string, description: "EKS cluster name" }
    - module: terraform/security/cognito
      vars:
        - { name: pool_id,   type: string, description: "Cognito user pool ID" }
        - { name: client_id, type: string, description: "Cognito app client ID" }
  gaps: []

preflight:
  status: passed
  checks:
    - { module: terraform/compute/aws/eks,                fmt: ok, validate: ok }
    - { module: terraform/traefik/shared,                  fmt: ok, validate: ok }
    - { module: terraform/security/cognito,                fmt: ok, validate: ok }
    - { module: terraform/observability/grafana-stack/k8s, fmt: ok, validate: ok }

inputs:
  status: complete
  vars:
    - { module: terraform/compute/aws/eks,  var: cluster_name, value: "nexovault-demo",    sensitive: false }
    - { module: terraform/security/cognito, var: pool_id,       value: "us-east-1_AbCdEf",  sensitive: true }
    - { module: terraform/security/cognito, var: client_id,     value: "1a2b3c4d5e",         sensitive: true }

deployment:
  status: deployed
  manifests_path: ~/poc-scenarios/nexovault-financial/manifests/
  deployed: true
  notes: "SA reviewed manifests and confirmed deploy"

snapshot:
  timestamp: "2026-05-28T14:32:00Z"
  status: pushed
  repo: "git@github.com:traefik-workshops/nexovault-poc.git"
  demo_md: ~/poc-scenarios/nexovault-financial/DEMO.md
  sensitive_values: redacted
```

---

## Rules

- Each command **appends** its section — never overwrites an existing section.
- Commands read only sections written by prior steps.
- Sensitive values (`sensitive: true`) are written to the local `poc.yaml` only. `/snapshot-poc` redacts them before any git push.
- The file is created by `/intake`. If `/intake` was skipped, it is created by `/extract-scenario`.
