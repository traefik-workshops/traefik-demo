# ai/sqlcl/k8s

Deploys the SQLcl MCP server as a Kubernetes Deployment + Service, optionally fronted by a Traefik Ingress.

## Example usage

```hcl
module "sqlcl" {
  source = "git::https://github.com/traefik/traefik-demo.git//terraform/ai/sqlcl/k8s?ref=v4.0.0"

  namespace = "sqlcl"
}
```

## Prerequisites

- A working Kubernetes cluster with the `kubernetes` provider configured.
- Traefik installed in-cluster if `ingress = true`.

## Notes

<!-- BEGIN_TF_DOCS -->


## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2.27 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | ~> 2.27 |

## Resources

| Name | Type |
| ---- | ---- |
| [kubernetes_deployment_v1.sqlcl](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/deployment_v1) | resource |
| [kubernetes_ingress_v1.sqlcl_traefik](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/ingress_v1) | resource |
| [kubernetes_service_v1.sqlcl](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_v1) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | The namespace of the sqlcl-mcp Deployment and Service | `string` | n/a | yes |
| <a name="input_container_port"></a> [container\_port](#input\_container\_port) | Pod port the MCP HTTP server binds to inside the container. Defaults to `8096`; only change when overriding the image entrypoint. | `number` | `8096` | no |
| <a name="input_image"></a> [image](#input\_image) | Container image for the SQLcl MCP server. Defaults to the public `zalbiraw/sqlcl:latest` build; override to pin a digest or use a mirrored registry. | `string` | `"zalbiraw/sqlcl:latest"` | no |
| <a name="input_ingress"></a> [ingress](#input\_ingress) | Enable Ingress for the sqlcl-mcp service | `bool` | `false` | no |
| <a name="input_ingress_annotations"></a> [ingress\_annotations](#input\_ingress\_annotations) | Additional metadata annotations merged onto the Ingress. Useful for custom router options beyond the three observability toggles. | `map(string)` | `{}` | no |
| <a name="input_ingress_domain"></a> [ingress\_domain](#input\_ingress\_domain) | The domain for the ingress, default is `cloud` | `string` | `"cloud"` | no |
| <a name="input_ingress_entrypoint"></a> [ingress\_entrypoint](#input\_ingress\_entrypoint) | The entrypoint to use for the ingress, default is `web` | `string` | `"web"` | no |
| <a name="input_ingress_observability"></a> [ingress\_observability](#input\_ingress\_observability) | Emit Traefik observability signals (access logs, metrics, traces) for the SQLcl MCP ingress router. Set to false to add the three `traefik.ingress.kubernetes.io/router.observability.*: "false"` annotations. Same switch shape as other k8s modules. | `bool` | `true` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of the sqlcl-mcp Deployment and Service | `string` | `"sqlcl-mcp"` | no |
| <a name="input_replicas"></a> [replicas](#input\_replicas) | Number of sqlcl-mcp Deployment replicas. Default `1` matches the demo posture — the MCP server is stateless so scaling is safe. | `number` | `1` | no |
| <a name="input_service_port"></a> [service\_port](#input\_service\_port) | Cluster-IP Service port exposing the MCP HTTP endpoint. Defaults to `8096` to match the image. | `number` | `8096` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
