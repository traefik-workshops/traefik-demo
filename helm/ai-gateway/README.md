# helm/ai-gateway

A generic AI Gateway Helm chart for Traefik Hub

- **Chart version:** `4.0.0` (slaved to the repo tag — see [`../AGENTS.md`](../AGENTS.md))
- **App version:** `1.0.0`

## Install

```bash
helm install my-ai-gateway oci://ghcr.io/traefik-workshops/ai-gateway --version 4.0.0
```

From source (for development against this repo):

```bash
cd helm/ai-gateway
helm dep update
helm install my-ai-gateway .
```

## Conventions

See [`../AGENTS.md`](../AGENTS.md) for chart conventions and [the root `AGENTS.md`](../../AGENTS.md) for repo-wide rules.

<!-- BEGIN_HELM_DOCS -->

## Requirements

| Name | Version |
|------|---------|
| kubernetes | (not pinned — pin in Chart.yaml) |
| helm | (apiVersion v2) |

## Dependencies

| Name | Version | Repository | Condition |
|------|---------|------------|-----------|
| presidio | `4.0.0` | `file://../presidio` | `sharedMiddlewares.contentGuardPresidio.enabled` |
| weaviate | `17.6.1` | `https://weaviate.github.io/weaviate-helm` | `sharedMiddlewares.semanticCache.enabled` |
| embeddings | `4.0.0` | `file://../embeddings` | `sharedMiddlewares.semanticCache.enabled` |

## Values

| Key | Default |
|-----|---------|
| `enabled` | `true` |
| `domain` | `"demo.traefik.ai"` |
| `entryPoints` | (list, 1 items) |
| `apiKeys` | (object) |
| `apiKeys.openai` | `""` |
| `apiKeys.gemini` | `""` |
| `apiKeys.anthropic` | `""` |
| `claudeMode` | (object) |
| `claudeMode.anthropic` | `false` |
| `multicluster` | (object) |
| `multicluster.enabled` | `false` |
| `multicluster.mode` | `"parent"` |
| `multicluster.parent` | (object) |
| `multicluster.parent.groups` | (object) |
| `multicluster.parent.groups.aiGateway` | `""` |
| `multicluster.child` | (object) |
| `multicluster.child.uplinkEntryPoints` | (object) |
| `multicluster.child.uplinkEntryPoints.aiGateway` | `"ai-gateway"` |
| `multicluster.child.groups` | (object) |
| `multicluster.child.groups.aiGateway` | `false` |
| `sharedMiddlewares` | (object) |
| `sharedMiddlewares.topicControl` | (object) |
| `sharedMiddlewares.topicControl.enabled` | `true` |
| `sharedMiddlewares.topicControl.host` | `"topic-control-nim"` |
| `sharedMiddlewares.topicControl.model` | `"nvidia/llama-3.1-nemoguard-8b-topic-control"` |
| `sharedMiddlewares.topicControl.systemPrompt` | `"You are a topic control agent. Determine if the user ques..."` |
| `sharedMiddlewares.topicControl.blockConditions` | (list, 1 items) |
| `sharedMiddlewares.contentSafety` | (object) |
| `sharedMiddlewares.contentSafety.enabled` | `true` |
| `sharedMiddlewares.contentSafety.host` | `"content-safety-nim"` |
| `sharedMiddlewares.contentSafety.model` | `"nvidia/llama-3.1-nemoguard-8b-content-safety"` |
| `sharedMiddlewares.contentSafety.blockConditions` | (list, 1 items) |
| `sharedMiddlewares.jailbreakDetection` | (object) |
| `sharedMiddlewares.jailbreakDetection.enabled` | `true` |
| `sharedMiddlewares.jailbreakDetection.host` | `"jailbreak-detection-nim"` |
| `sharedMiddlewares.jailbreakDetection.scoreThreshold` | `"0.85"` |
| `sharedMiddlewares.graniteGuardian` | (object) |
| `sharedMiddlewares.graniteGuardian.enabled` | `true` |
| `sharedMiddlewares.graniteGuardian.host` | `"granite-guardian"` |
| `sharedMiddlewares.contentGuardPresidio` | (object) |
| `sharedMiddlewares.contentGuardPresidio.enabled` | `true` |
| `sharedMiddlewares.contentGuardPresidio.request` | (object) |
| `sharedMiddlewares.contentGuardPresidio.request.rules` | `"[]"` |
| `sharedMiddlewares.contentGuardPresidio.response` | (object) |
| `sharedMiddlewares.contentGuardPresidio.response.rules` | (list, 1 items) |
| `sharedMiddlewares.contentGuardRegex` | (object) |
| `sharedMiddlewares.contentGuardRegex.enabled` | `false` |
| `sharedMiddlewares.contentGuardRegex.request` | (object) |
| `sharedMiddlewares.contentGuardRegex.request.rules` | `"[]"` |
| `sharedMiddlewares.contentGuardRegex.response` | (object) |
| `sharedMiddlewares.contentGuardRegex.response.rules` | `"[]"` |
| `sharedMiddlewares.parallelGuard` | (object) |
| `sharedMiddlewares.parallelGuard.enabled` | `false` |
| `sharedMiddlewares.semanticCache` | (object) |
| `sharedMiddlewares.semanticCache.enabled` | `false` |
| `sharedMiddlewares.semanticCache.collectionName` | `"ai-gateway"` |
| `endpoints` | (list, 3 items) |
| `presidio` | `{}` |
| `weaviate` | (object) |
| `weaviate.service` | (object) |
| `weaviate.service.type` | `"ClusterIP"` |
| `weaviate.grpcService` | (object) |
| `weaviate.grpcService.enabled` | `false` |
| `embeddings` | (object) |
| `embeddings.model` | `"nomic-embed-text"` |
| `nims` | (object) |
| `nims.enabled` | `false` |
| `nims.ngcToken` | `""` |
| `nims.types` | (list, 3 items) |

<!-- END_HELM_DOCS -->
