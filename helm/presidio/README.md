# helm/presidio

A Helm chart for Microsoft Presidio Analyzer

- **Chart version:** `4.0.0` (slaved to the repo tag — see [`../AGENTS.md`](../AGENTS.md))
- **App version:** `2.2.358`

## Install

```bash
helm install my-presidio oci://ghcr.io/traefik-workshops/presidio --version 4.0.0
```

From source (for development against this repo):

```bash
cd helm/presidio
helm dep update
helm install my-presidio .
```

## Related

There is also a Terraform module that ships Presidio for the same role:
[`terraform/ai/presidio/k8s`](../../terraform/ai/presidio/k8s). Pick which:

- Use **this chart** in any GitOps or `helm install` workflow — it is the
  shape consumed by the umbrella `ai-gateway` chart for AI Gateway demos.
- Use the **Terraform module** when you're already building the cluster with
  Terraform and want the Presidio resources in the same plan/state. Note
  that the module wires Presidio with raw `kubernetes_deployment_v1` /
  `kubernetes_service_v1` rather than wrapping this chart, so its values
  surface is smaller — extend it only for trivial demos.

## Conventions

See [`../AGENTS.md`](../AGENTS.md) for chart conventions and [the root `AGENTS.md`](../../AGENTS.md) for repo-wide rules.

<!-- BEGIN_HELM_DOCS -->

## Requirements

| Name | Version |
|------|---------|
| kubernetes | (not pinned — pin in Chart.yaml) |
| helm | (apiVersion v2) |

## Values

| Key | Default |
|-----|---------|
| `image` | (object) |
| `image.repository` | `"mcr.microsoft.com/presidio-analyzer"` |
| `image.tag` | `"2.2.358"` |
| `image.pullPolicy` | `"IfNotPresent"` |
| `service` | (object) |
| `service.type` | `"ClusterIP"` |
| `service.port` | `3000` |
| `resources` | (object) |
| `resources.limits` | (object) |
| `resources.limits.cpu` | `"1"` |
| `resources.limits.memory` | `"2Gi"` |
| `resources.requests` | (object) |
| `resources.requests.cpu` | `"200m"` |
| `resources.requests.memory` | `"1Gi"` |

<!-- END_HELM_DOCS -->
