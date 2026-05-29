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
| [kubernetes_ingress_v1.oracle_23ai_traefik](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/ingress_v1) | resource |
| [kubernetes_service_v1.db](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_v1) | resource |
| [kubernetes_stateful_set.db](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/stateful_set) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | The namespace of the oracle-db StatefulSet and Service | `string` | n/a | yes |
| <a name="input_container_port"></a> [container\_port](#input\_container\_port) | Pod port the TNS listener binds to inside the container. Defaults to `1521`; only change when overriding the image entrypoint. | `number` | `1521` | no |
| <a name="input_image"></a> [image](#input\_image) | Container image for the Oracle 23ai database. Defaults to the public Oracle Free image; override to pin a tag or point at a mirrored registry. | `string` | `"container-registry.oracle.com/database/free:latest"` | no |
| <a name="input_ingress"></a> [ingress](#input\_ingress) | Enable Ingress for the oracle-db service | `bool` | `false` | no |
| <a name="input_ingress_annotations"></a> [ingress\_annotations](#input\_ingress\_annotations) | Additional metadata annotations merged onto the Ingress. Useful for custom router options beyond the three observability toggles. | `map(string)` | `{}` | no |
| <a name="input_ingress_domain"></a> [ingress\_domain](#input\_ingress\_domain) | The domain for the ingress, default is `cloud` | `string` | `"cloud"` | no |
| <a name="input_ingress_entrypoint"></a> [ingress\_entrypoint](#input\_ingress\_entrypoint) | The entrypoint to use for the ingress, default is `web` | `string` | `"web"` | no |
| <a name="input_ingress_observability"></a> [ingress\_observability](#input\_ingress\_observability) | Emit Traefik observability signals (access logs, metrics, traces) for the Oracle 23ai ingress router. Set to false to add the three `traefik.ingress.kubernetes.io/router.observability.*: "false"` annotations. Same switch shape as other k8s modules. | `bool` | `true` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of the oracle-db StatefulSet and Service | `string` | `"oracledb"` | no |
| <a name="input_oracle_characterset"></a> [oracle\_characterset](#input\_oracle\_characterset) | Database character set passed via the `ORACLE_CHARACTERSET` env var at first boot. AL32UTF8 is the Oracle-recommended UTF-8 default; only change for legacy compatibility. | `string` | `"AL32UTF8"` | no |
| <a name="input_oracle_pwd"></a> [oracle\_pwd](#input\_oracle\_pwd) | SYS/SYSTEM/PDBADMIN password injected via the `ORACLE_PWD` env var. Demo default is intentionally low-effort — rotate when exposing the DB outside the cluster. | `string` | `"topSecretpa33word"` | no |
| <a name="input_replicas"></a> [replicas](#input\_replicas) | Number of Oracle 23ai StatefulSet replicas. Default `1` is fine for demos; the chart isn't HA-aware so larger values aren't useful without external coordination. | `number` | `1` | no |
| <a name="input_service_port"></a> [service\_port](#input\_service\_port) | Cluster-IP Service port that exposes the Oracle TNS listener. Defaults to the Oracle standard `1521`. | `number` | `1521` | no |
| <a name="input_storage_size"></a> [storage\_size](#input\_storage\_size) | PersistentVolumeClaim size requested per replica for `/opt/oracle/oradata`. Default `50Gi` covers a demo dataset; bump for benchmarks. | `string` | `"50Gi"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
