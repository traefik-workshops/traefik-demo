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

## Resources

| Name | Type |
|------|------|
| `kubernetes_deployment_v1.sqlcl` | resource |
| `kubernetes_service_v1.sqlcl` | resource |
| `kubernetes_ingress_v1.sqlcl-traefik` | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| namespace | The namespace of the sqlcl-mcp Deployment and Service | `string` | n/a | yes |
| container_port | n/a | `number` | `8096` | no |
| image | n/a | `string` | `"zalbiraw/sqlcl:latest"` | no |
| ingress | Enable Ingress for the sqlcl-mcp service | `bool` | `false` | no |
| ingress_annotations | Additional metadata annotations merged onto the Ingress. Useful for custom router options beyond the three observability toggles. | `map(string)` | `{}` | no |
| ingress_domain | The domain for the ingress, default is `cloud` | `string` | `"cloud"` | no |
| ingress_entrypoint | The entrypoint to use for the ingress, default is `web` | `string` | `"web"` | no |
| ingress_observability | Emit Traefik observability signals (access logs, metrics, traces) for the SQLcl MCP ingress router. Set to false to add the three `traefik.ingress.kubernetes.io/router.observability.*: "false"` annotations. Same switch shape as other k8s modules. | `bool` | `true` | no |
| name | The name of the sqlcl-mcp Deployment and Service | `string` | `"sqlcl-mcp"` | no |
| replicas | n/a | `number` | `1` | no |
| service_port | n/a | `number` | `8096` | no |

<!-- END_TF_DOCS -->
