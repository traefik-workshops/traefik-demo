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
|------|---------|
| helm | ~> 3.0 |

## Providers

| Name | Source | Version |
|------|--------|---------|
| helm | `hashicorp/helm` | `~> 3.0` |

## Resources

| Name | Type |
|------|------|
| `helm_release.argocd` | resource |
| `kubernetes_ingress_v1.argocd-traefik` | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| admin_password 🔒 | Admin password for ArgoCD | `string` | n/a | yes |
| namespace | Namespace for the ArgoCD deployment | `string` | n/a | yes |
| ingress | Enable Ingress for the ArgoCD deployment. | `bool` | `false` | no |
| ingress_annotations | Additional metadata annotations merged onto the Ingress. Useful for custom router options beyond the three observability toggles. | `map(string)` | `{}` | no |
| ingress_domain | The domain for the ingress, default is `cloud` | `string` | `"cloud"` | no |
| ingress_entrypoint | The entrypoint to use for the ingress, default is `traefik` | `string` | `"traefik"` | no |
| ingress_observability | Emit Traefik observability signals (access logs, metrics, traces) for the ArgoCD ingress router. Set to false to add the three `traefik.ingress.kubernetes.io/router.observability.*: "false"` annotations. Same switch shape as other k8s modules. | `bool` | `true` | no |
| name | The name of the ArgoCD release | `string` | `"argocd"` | no |

<!-- END_TF_DOCS -->
