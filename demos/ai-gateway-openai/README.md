# demos/ai-gateway-openai

Traefik Hub **AI Gateway** in front of an OpenAI-compatible API on k3d, with
content-guards and a token rate-limit. White-labeled from a real engagement
(`clients/Mercury`).

The gateway chain (guards first, then auth) does:

1. **Regex content-guard** — blocks any prompt containing an email address.
2. **Presidio content-guard** — blocks prompts containing a credit card or SSN
   (deterministic Presidio recognizers, so it works on released Hub) and masks
   them on the response.
3. **Token rate-limit** — Redis-backed budget over `.usage.total_tokens`.
4. **chat-completion auth-injection** — sets the upstream `Authorization` header
   from a Kubernetes Secret, so clients never hold the provider key.

## What it proves

- The AI gateway can enforce PII/secret policy on prompts *before* they leave
  your cluster, and inject the provider credential server-side.
- Guard rejections short-circuit at the gateway (HTTP 200 + a block message),
  so they're demonstrable without ever calling a paid backend.

## Prerequisites

- `terraform`, `k3d`, `kubectl`
- A **Traefik Hub token** (offline JWT) — the AI gateway is licensed. Put it in
  `terraform.tfvars`. Get one at <https://hub.traefik.io>.
- An OpenAI key is **optional** — only the happy-path scenario uses it. Point
  `backend_external_name` at a mock for a fully keyless run.

## Run it

```bash
cp terraform.tfvars.example terraform.tfvars   # add your Hub token
make up
make scenarios
make down
```

## Scenarios

`make scenarios` posts to `/v1/chat/completions` and asserts:

| Prompt contains | Guard | Expected |
|---|---|---|
| `4111 1111 1111 1111` (test Visa) | Presidio | blocked |
| `078-05-1120` (test SSN) | Presidio | blocked |
| `alice@example.com` | regex | blocked |
| clean text | — | passes the guards, reaches the upstream |

Test data is synthetic (standard test card / SSN), not real PII.

## Conventions

- Module sources are **relative** (`../../terraform/...`); the AI-gateway CRDs
  (Middlewares + IngressRoute) are applied as `kubectl_manifest`. See
  [`../AGENTS.md`](../AGENTS.md).
- **No secrets in git.** Keys go in `terraform.tfvars` (gitignored); only
  `terraform.tfvars.example` is committed.
