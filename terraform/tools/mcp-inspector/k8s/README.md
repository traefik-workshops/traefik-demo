# tools/mcp-inspector/k8s

Deploys the MCP Inspector UI on Kubernetes as a Deployment + Service, optionally fronted by a Traefik Ingress.

## Example usage

```hcl
module "mcp_inspector" {
  source = "git::https://github.com/traefik/terraform-demo-modules.git//terraform/tools/mcp-inspector/k8s?ref=v3.2.0"

  namespace = "mcp"
}
```

## Prerequisites

- A working Kubernetes cluster with `kubernetes` and `helm` providers configured.
- Traefik installed in-cluster if `ingress = true`.

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name | Version |
|------|---------|
| kubernetes | >= 2.0 |
| helm | ~> 3.0 |

## Providers

| Name | Source | Version |
|------|--------|---------|
| kubernetes | `hashicorp/kubernetes` | `>= 2.0` |
| helm | `hashicorp/helm` | `~> 3.0` |

## Resources

| Name | Type |
|------|------|
| `kubernetes_deployment_v1.mcp_inspector` | resource |
| `kubernetes_service_v1.mcp_inspector` | resource |
| `kubernetes_ingress_v1.mcp_inspector_traefik` | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| namespace | The namespace of the mcp-inspector Deployment and Service | `string` | n/a | yes |
| ingress | Enable Ingress for the mcp-inspector service | `bool` | `false` | no |
| ingress_annotations | Additional metadata annotations merged onto the Ingress. Useful for custom router options beyond the three observability toggles. | `map(string)` | `{}` | no |
| ingress_domain | The domain for the ingress, default is `cloud` | `string` | `"cloud"` | no |
| ingress_entrypoint | The entrypoint to use for the ingress, default is `web` | `string` | `"web"` | no |
| ingress_observability | Emit Traefik observability signals (access logs, metrics, traces) for the MCP Inspector ingress router. Set to false to add the three `traefik.ingress.kubernetes.io/router.observability.*: "false"` annotations. Same switch shape as other k8s modules. | `bool` | `true` | no |
| name | The name of the mcp-inspector Deployment and Service | `string` | `"mcp-inspector"` | no |
| replicas | n/a | `number` | `1` | no |

<!-- END_TF_DOCS -->
