# ai/open-webui/k8s

Deploys Open WebUI on a Kubernetes cluster via Helm, with optional Traefik ingress, OpenAI-compatible backends, and MCP connection configuration.

## Example usage

```hcl
module "open_webui" {
  source = "git::https://github.com/traefik/traefik-demo.git//terraform/ai/open-webui/k8s?ref=v3.2.0"

  name      = "open-webui"
  namespace = "open-webui"
}
```

## Prerequisites

- A working Kubernetes cluster with the `helm` provider configured.
- Traefik installed in-cluster if `ingress = true`.

## Notes

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name | Version |
|------|---------|
| helm | ~> 3.0 |

## Providers

| Name | Source | Version |
|------|--------|---------|
| helm | `hashicorp/helm` | `~> 3.0` |

## Resources

| Name | Type |
|------|------|
| `helm_release.open_webui` | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| extra_values | Extra values to pass to the Grafana deployment. | `any` | `{}` | no |
| ingress | Enable ingress for the open-webui release | `bool` | `false` | no |
| ingress_annotations | Additional metadata annotations merged onto the Ingress. Useful for custom router options beyond the three observability toggles. | `map(string)` | `{}` | no |
| ingress_domain | The domain for the ingress, default is `cloud` | `string` | `"cloud"` | no |
| ingress_entrypoint | The entrypoint to use for the ingress, default is `web` | `string` | `"web"` | no |
| ingress_observability | Emit Traefik observability signals (access logs, metrics, traces) for the Open WebUI ingress router. Set to false to add the three `traefik.ingress.kubernetes.io/router.observability.*: "false"` annotations. Same switch shape as other k8s modules. | `bool` | `true` | no |
| mcp_connections | MCP connections with required Open WebUI fields | `list(object({type = optional(string, "mcp"), url = string, path = optional(string, "/"), auth_type = optional(string, "bearer"), key = optional(string, ""), config = optional(map(string), {), info = object({id = string, name = string, description = string)))` | `[]` | no |
| name | The name of the open-webui release | `string` | `"open-webui"` | no |
| namespace | The namespace of the milvus release | `string` | `"milvus"` | no |
| openai_api_base_urls | OpenAI API base URLs | `list(string)` | `[]` | no |
| openai_api_keys | OpenAI API keys | `list(string)` | `[]` | no |

<!-- END_TF_DOCS -->
