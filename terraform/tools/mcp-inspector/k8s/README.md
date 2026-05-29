# tools/mcp-inspector/k8s

Deploys the MCP Inspector UI on Kubernetes as a Deployment + Service, optionally fronted by a Traefik Ingress.

## Example usage

```hcl
module "mcp_inspector" {
  source = "git::https://github.com/traefik/traefik-demo.git//terraform/tools/mcp-inspector/k8s?ref=v4.0.0"

  namespace = "mcp"
}
```

## Prerequisites

- A working Kubernetes cluster with `kubernetes` and `helm` providers configured.
- Traefik installed in-cluster if `ingress = true`.

<!-- BEGIN_TF_DOCS -->


## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >= 2.0 |

## Resources

| Name | Type |
| ---- | ---- |
| [kubernetes_deployment_v1.mcp_inspector](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/deployment_v1) | resource |
| [kubernetes_ingress_v1.mcp_inspector_traefik](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/ingress_v1) | resource |
| [kubernetes_service_v1.mcp_inspector](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_v1) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | The namespace of the mcp-inspector Deployment and Service | `string` | n/a | yes |
| <a name="input_ingress"></a> [ingress](#input\_ingress) | Enable Ingress for the mcp-inspector service | `bool` | `false` | no |
| <a name="input_ingress_annotations"></a> [ingress\_annotations](#input\_ingress\_annotations) | Additional metadata annotations merged onto the Ingress. Useful for custom router options beyond the three observability toggles. | `map(string)` | `{}` | no |
| <a name="input_ingress_domain"></a> [ingress\_domain](#input\_ingress\_domain) | The domain for the ingress, default is `cloud` | `string` | `"cloud"` | no |
| <a name="input_ingress_entrypoint"></a> [ingress\_entrypoint](#input\_ingress\_entrypoint) | The entrypoint to use for the ingress, default is `web` | `string` | `"web"` | no |
| <a name="input_ingress_observability"></a> [ingress\_observability](#input\_ingress\_observability) | Emit Traefik observability signals (access logs, metrics, traces) for the MCP Inspector ingress router. Set to false to add the three `traefik.ingress.kubernetes.io/router.observability.*: "false"` annotations. Same switch shape as other k8s modules. | `bool` | `true` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of the mcp-inspector Deployment and Service | `string` | `"mcp-inspector"` | no |
| <a name="input_replicas"></a> [replicas](#input\_replicas) | Number of mcp-inspector Deployment replicas. | `number` | `1` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_dashboard_url"></a> [dashboard\_url](#output\_dashboard\_url) | URL of the MCP Inspector UI. Reachable when var.ingress = true. |
| <a name="output_namespace"></a> [namespace](#output\_namespace) | Namespace the MCP Inspector release is installed into. |
| <a name="output_service_endpoint"></a> [service\_endpoint](#output\_service\_endpoint) | In-cluster MCP Inspector service URL. |
<!-- END_TF_DOCS -->
