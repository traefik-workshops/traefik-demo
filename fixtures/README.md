# Fixtures — sa-assistant test inputs

Synthetic prospect conversations for testing the `sa-assistant` skill and `/extract-scenario` command.

Each subfolder is a self-contained input that mimics what an SA would receive from a real prospect.

| Folder | Company | Cloud | Core use case |
|---|---|---|---|
| `example-1/` | NexoVault Financial | AWS / EKS | API management + Cognito SSO + Grafana observability |
| `example-2/` | MedPilot Health | Azure / AKS | AI chatbot with PII masking (HIPAA) + EntraID |
| `example-3/` | Cartify Commerce | GCP / GKE | MCP gateway for internal AI agents + Keycloak |
| `example-4/` | Montréal 2027 Candidature Committee | N/A | **Wrong recipient** — construction RFQ for an Eiffel Tower replica, not a Traefik prospect |
| `example-impossible/` | SocialLoop Media | GCP / GKE | **Fictional product** — "Traefik Facebook Gateway" does not exist |

## Usage

```
/extract-scenario fixtures/example-1/transcript.md
/extract-scenario fixtures/          # batch mode — produces one YAML per example
```

## What each example exercises

- **example-1**: Happy path — all modules exist, no gaps, clear cloud/auth/observability signals.
- **example-2**: Gap detection — EntraID has a Terraform module (`terraform/security/entraid`) but the SA notes flag it as a potential issue; also tests CPU-LLM + PII path.
- **example-3**: MCP gateway path — exercises `ai-gateway-dependencies`, `mcp-inspector`, Keycloak realm import question, and the "nice-to-have" Milvus layer.
- **example-4**: Wrong-recipient / off-topic rejection — email is a CAD $380M construction RFQ (Eiffel Tower replica, Île Notre-Dame). Intake should immediately reject: not a software prospect, no cloud/k8s context, zero Traefik relevance.
- **example-impossible**: Hallucinated product detection — prospect cites "Traefik Facebook Gateway" (non-existent), references fictional features (webhook relay, ad-spend dashboard, token vault). Feasibility check should reject with clear "product does not exist" finding.
