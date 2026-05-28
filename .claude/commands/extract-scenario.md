# Extract Scenario

Extract canonical signals from the normalized intake document. Output is a flat, deduplicated signal list for prospect context. Module mapping happens in `/feasibility-check`.

## Invocation

```
/extract-scenario
/extract-scenario <path-to-normalized.md>
```

With no argument: reads `normalized_path` from the `intake:` section of `poc.yaml` in the current working directory.

With a path: reads that file directly (useful when running without a prior `/intake`).

## Step 1 — Read source

Load the normalized document from intake. If no intake was run:
- Accept raw file directly.
- Warn SA that no normalization was performed — multi-doc contradictions may be unresolved.

## Step 2 — Extract prospect context

| Field | What to look for |
|---|---|
| Prospect name | Company name, domain, sender org |
| Industry | Financial services, healthcare, retail, public sector, etc. |
| Cloud | Provider mentioned (AWS, Azure, GCP, Oracle, Nutanix, local) |
| Constraints | Compliance (GDPR, HIPAA), air-gap, no GPU, budget signals |
| Timeline | Demo urgency — "next week", "end of quarter" |
| Key stakeholders | DevOps, platform team, CISO, etc. |

## Step 3 — Extract signals

Scan the document for every technology name, product, protocol, compliance framework, and cloud service mentioned. For each:

1. Normalize to canonical lowercase form:
   - `"Amazon"` / `"AWS"` / `"EKS"` → `aws`
   - `"Azure AD"` / `"Entra"` / `"EntraID"` → `entraid`
   - `"Google Cloud"` / `"GKE"` → `gcp`
   - `"Kubernetes"` / `"k8s"` → `kubernetes`
   - `"on-prem"` / `"on-premise"` / `"private cloud"` → `on-prem`
2. Record source: `email-thread` / `call-notes` / `slack` / `direct`.
3. Deduplicate — if the same canonical signal appears in multiple sources, keep one entry with all sources listed.

## Step 4 — Confirm with SA

Print the extracted context and signal list to chat:

```
Prospect:    <name>
Industry:    <industry>
Cloud:       <provider>
Constraints: <list or "none identified">
Timeline:    <urgency or "not mentioned">

Signals extracted:
  aws           (email-thread, call-notes)
  cognito       (email-thread)
  kubernetes    (call-notes)
  grafana       (call-notes)
  airlines      (call-notes)

Questions:
  1. <anything ambiguous or missing>

Confirm? (yes / add <signal> / remove <signal> / re-run intake)
```

Wait for SA confirmation. SA can:
- Confirm → proceed to write output.
- Add / remove signals → update list and re-confirm.
- Re-run intake → stop, SA goes back to `/intake`.

## Step 5 — Append to poc.yaml

```yaml
scenario:
  prospect_name: <name>
  industry: <industry>
  cloud: <provider>           # aws | azure | gcp | oracle | nutanix | runpod | local
  constraints:
    - "<constraint>"
  timeline: "<urgency>"
  signals:
    - { value: aws,     sources: [email-thread] }
    - { value: cognito, sources: [email-thread] }
  questions:
    - "<open question>"
```

## Rules

- Extract signals only — do not map to modules.
- If cloud is ambiguous (multiple providers mentioned), list both in signals and add a question — do not pick silently.
- If a signal is mentioned once in passing (e.g., "we heard about Istio"), note it but do not promote it — SA decides.
- Batch mode (directory or CSV input): write one poc.yaml per prospect to `~/poc-scenarios/<slug>/poc.yaml` without interactive confirmation.
