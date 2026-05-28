# tools/k6-operator/k8s/loadgen/aigateway

Renders k6 `TestRun` manifests for the AI-Gateway load test (per-user JWT, multi-turn conversations across one or more model APIs).

## Example usage

```hcl
module "loadgen_aigateway" {
  source = "git::https://github.com/traefik/traefik-demo.git//terraform/tools/k6-operator/k8s/loadgen/aigateway?ref=v4.0.0"

  apis                   = [{ url = "https://aigw.demo.traefik.ai", models = ["llama3.1:8b"] }]
  users                  = [{ username = "admin", password = "..." }]
  keycloak_url           = "https://keycloak.demo.traefik.ai/realms/demo/protocol/openid-connect/token"
  keycloak_client_id     = "loadgen"
  keycloak_client_secret = var.keycloak_client_secret
}
```

## Prerequisites

- A working Kubernetes cluster with the `kubectl` provider configured.
- The k6 Operator installed in-cluster (see `tools/k6-operator/k8s`).
- A reachable Keycloak realm with the configured client.

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name | Version |
|------|---------|
| kubectl | ~> 1.0 |

## Providers

| Name | Source | Version |
|------|--------|---------|
| kubectl | `gavinbunney/kubectl` | `~> 1.0` |

## Resources

| Name | Type |
|------|------|
| `kubectl_manifest.aigateway_traffic_configmap` | resource |
| `kubectl_manifest.aigateway_traffic_testrun` | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| apis | n/a | `list(object({url = string, models = list(string)))` | n/a | yes |
| keycloak_client_id | Keycloak client ID | `string` | n/a | yes |
| keycloak_client_secret 🔒 | Keycloak client secret | `string` | n/a | yes |
| keycloak_url | Keycloak token endpoint URL | `string` | n/a | yes |
| users | List of users with credentials for JWT authentication | `list(object({username = string, password = string))` | n/a | yes |
| max_messages_per_conversation | Maximum number of messages in a conversation | `number` | `8` | no |
| min_messages_per_conversation | Minimum number of messages in a conversation | `number` | `3` | no |

<!-- END_TF_DOCS -->
