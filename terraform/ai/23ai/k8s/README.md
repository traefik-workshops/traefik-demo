# ai/23ai/k8s

Deploys an Oracle Database 23ai (Free) StatefulSet with a matching Service into a Kubernetes cluster, optionally fronted by a Traefik Ingress.

## Example usage

```hcl
module "oracle_23ai" {
  source = "git::https://github.com/traefik/traefik-demo.git//terraform/ai/23ai/k8s?ref=v4.0.0"

  namespace = "oracle"
}
```

## Prerequisites

- A working Kubernetes cluster with the `kubernetes` provider configured.
- Traefik installed in-cluster if `ingress = true`.

## Notes

- The default `oracle_pwd` is a demo value — override it for any non-throwaway deployment.

<!-- BEGIN_TF_DOCS -->

## Resources

| Name | Type |
|------|------|
| `kubernetes_stateful_set.db` | resource |
| `kubernetes_service_v1.db` | resource |
| `kubernetes_ingress_v1.oracle-23ai-traefik` | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| namespace | The namespace of the oracle-db StatefulSet and Service | `string` | n/a | yes |
| container_port | n/a | `number` | `1521` | no |
| image | n/a | `string` | `"container-registry.oracle.com/database/free:latest"` | no |
| ingress | Enable Ingress for the oracle-db service | `bool` | `false` | no |
| ingress_annotations | Additional metadata annotations merged onto the Ingress. Useful for custom router options beyond the three observability toggles. | `map(string)` | `{}` | no |
| ingress_domain | The domain for the ingress, default is `cloud` | `string` | `"cloud"` | no |
| ingress_entrypoint | The entrypoint to use for the ingress, default is `web` | `string` | `"web"` | no |
| ingress_observability | Emit Traefik observability signals (access logs, metrics, traces) for the Oracle 23ai ingress router. Set to false to add the three `traefik.ingress.kubernetes.io/router.observability.*: "false"` annotations. Same switch shape as other k8s modules. | `bool` | `true` | no |
| name | The name of the oracle-db StatefulSet and Service | `string` | `"oracledb"` | no |
| oracle_characterset | Oracle database character set. | `string` | `"AL32UTF8"` | no |
| oracle_pwd | Oracle database password. | `string` | `"topSecretpa33word"` | no |
| replicas | n/a | `number` | `1` | no |
| service_port | n/a | `number` | `1521` | no |
| storage_size | n/a | `string` | `"50Gi"` | no |

<!-- END_TF_DOCS -->
