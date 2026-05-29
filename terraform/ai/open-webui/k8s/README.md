# ai/open-webui/k8s

Deploys Open WebUI on a Kubernetes cluster via Helm, with optional Traefik ingress, OpenAI-compatible backends, and MCP connection configuration.

## Example usage

```hcl
module "open_webui" {
  source = "git::https://github.com/traefik/traefik-demo.git//terraform/ai/open-webui/k8s?ref=v4.0.0"

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
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | ~> 3.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_helm"></a> [helm](#provider\_helm) | ~> 3.0 |

## Resources

| Name | Type |
| ---- | ---- |
| [helm_release.open_webui](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_extra_values"></a> [extra\_values](#input\_extra\_values) | Extra values to pass to the Grafana deployment. | `any` | `{}` | no |
| <a name="input_ingress"></a> [ingress](#input\_ingress) | Enable ingress for the open-webui release | `bool` | `false` | no |
| <a name="input_ingress_annotations"></a> [ingress\_annotations](#input\_ingress\_annotations) | Additional metadata annotations merged onto the Ingress. Useful for custom router options beyond the three observability toggles. | `map(string)` | `{}` | no |
| <a name="input_ingress_domain"></a> [ingress\_domain](#input\_ingress\_domain) | The domain for the ingress, default is `cloud` | `string` | `"cloud"` | no |
| <a name="input_ingress_entrypoint"></a> [ingress\_entrypoint](#input\_ingress\_entrypoint) | The entrypoint to use for the ingress, default is `web` | `string` | `"web"` | no |
| <a name="input_ingress_observability"></a> [ingress\_observability](#input\_ingress\_observability) | Emit Traefik observability signals (access logs, metrics, traces) for the Open WebUI ingress router. Set to false to add the three `traefik.ingress.kubernetes.io/router.observability.*: "false"` annotations. Same switch shape as other k8s modules. | `bool` | `true` | no |
| <a name="input_mcp_connections"></a> [mcp\_connections](#input\_mcp\_connections) | MCP connections with required Open WebUI fields | <pre>list(object({<br/>    type      = optional(string, "mcp")<br/>    url       = string<br/>    path      = optional(string, "/")<br/>    auth_type = optional(string, "bearer")<br/>    key       = optional(string, "")<br/>    config    = optional(map(string), {})<br/>    info = object({<br/>      id          = string<br/>      name        = string<br/>      description = string<br/>    })<br/>  }))</pre> | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of the open-webui release | `string` | `"open-webui"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace for the Open WebUI Helm release. | `string` | `"open-webui"` | no |
| <a name="input_openai_api_base_urls"></a> [openai\_api\_base\_urls](#input\_openai\_api\_base\_urls) | OpenAI API base URLs | `list(string)` | `[]` | no |
| <a name="input_openai_api_keys"></a> [openai\_api\_keys](#input\_openai\_api\_keys) | OpenAI API keys | `list(string)` | `[]` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
