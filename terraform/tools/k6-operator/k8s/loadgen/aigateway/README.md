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
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_kubectl"></a> [kubectl](#requirement\_kubectl) | ~> 1.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_kubectl"></a> [kubectl](#provider\_kubectl) | ~> 1.0 |

## Resources

| Name | Type |
| ---- | ---- |
| [kubectl_manifest.aigateway_traffic_configmap](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/resources/manifest) | resource |
| [kubectl_manifest.aigateway_traffic_testrun](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/resources/manifest) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_apis"></a> [apis](#input\_apis) | AI Gateway API endpoints the k6 scenario rotates through. Each entry is `{ url, models }` — the scenario picks an API at random per request, then a model from that API's list. | <pre>list(object({<br/>    url    = string<br/>    models = list(string)<br/>  }))</pre> | n/a | yes |
| <a name="input_keycloak_client_id"></a> [keycloak\_client\_id](#input\_keycloak\_client\_id) | Keycloak client ID | `string` | n/a | yes |
| <a name="input_keycloak_client_secret"></a> [keycloak\_client\_secret](#input\_keycloak\_client\_secret) | Keycloak client secret | `string` | n/a | yes |
| <a name="input_keycloak_url"></a> [keycloak\_url](#input\_keycloak\_url) | Keycloak token endpoint URL | `string` | n/a | yes |
| <a name="input_users"></a> [users](#input\_users) | List of users with credentials for JWT authentication | <pre>list(object({<br/>    username = string<br/>    password = string<br/>  }))</pre> | n/a | yes |
| <a name="input_max_messages_per_conversation"></a> [max\_messages\_per\_conversation](#input\_max\_messages\_per\_conversation) | Maximum number of messages in a conversation | `number` | `8` | no |
| <a name="input_min_messages_per_conversation"></a> [min\_messages\_per\_conversation](#input\_min\_messages\_per\_conversation) | Minimum number of messages in a conversation | `number` | `3` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
