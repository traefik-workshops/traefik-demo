# tools/argocd/k8s

Deploys ArgoCD on Kubernetes via Helm with an explicit admin password and optional Traefik ingress.

## Example usage

```hcl
module "argocd" {
  source = "git::https://github.com/traefik/traefik-demo.git//terraform/tools/argocd/k8s?ref=v4.0.0"

  name           = "argocd"
  namespace      = "argocd"
  admin_password = var.argocd_admin_password
}
```

## Prerequisites

- A working Kubernetes cluster with the `helm` provider configured.
- Traefik installed in-cluster if `ingress = true`.

<!-- BEGIN_TF_DOCS -->


## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | ~> 3.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_helm"></a> [helm](#provider\_helm) | ~> 3.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | ~> 2.0 |

## Resources

| Name | Type |
| ---- | ---- |
| [helm_release.argocd](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_ingress_v1.argocd_traefik](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/ingress_v1) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_admin_password"></a> [admin\_password](#input\_admin\_password) | Admin password for ArgoCD | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace for the ArgoCD deployment | `string` | n/a | yes |
| <a name="input_ingress"></a> [ingress](#input\_ingress) | Enable Ingress for the ArgoCD deployment. | `bool` | `false` | no |
| <a name="input_ingress_annotations"></a> [ingress\_annotations](#input\_ingress\_annotations) | Additional metadata annotations merged onto the Ingress. Useful for custom router options beyond the three observability toggles. | `map(string)` | `{}` | no |
| <a name="input_ingress_domain"></a> [ingress\_domain](#input\_ingress\_domain) | The domain for the ingress, default is `cloud` | `string` | `"cloud"` | no |
| <a name="input_ingress_entrypoint"></a> [ingress\_entrypoint](#input\_ingress\_entrypoint) | The entrypoint to use for the ingress, default is `traefik` | `string` | `"traefik"` | no |
| <a name="input_ingress_observability"></a> [ingress\_observability](#input\_ingress\_observability) | Emit Traefik observability signals (access logs, metrics, traces) for the ArgoCD ingress router. Set to false to add the three `traefik.ingress.kubernetes.io/router.observability.*: "false"` annotations. Same switch shape as other k8s modules. | `bool` | `true` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of the ArgoCD release | `string` | `"argocd"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_admin_password"></a> [admin\_password](#output\_admin\_password) | ArgoCD admin password — same value as var.admin\_password. |
| <a name="output_admin_user"></a> [admin\_user](#output\_admin\_user) | ArgoCD admin username (Helm chart default). |
| <a name="output_dashboard_url"></a> [dashboard\_url](#output\_dashboard\_url) | URL of the ArgoCD dashboard. Reachable when var.ingress = true. |
| <a name="output_namespace"></a> [namespace](#output\_namespace) | Namespace the ArgoCD release is installed into. |
<!-- END_TF_DOCS -->
