# tools/nginx/k8s

Deploys NGINX on Kubernetes via Helm.

## Example usage

```hcl
module "nginx" {
  source = "git::https://github.com/traefik/terraform-demo-modules.git//terraform/tools/nginx/k8s?ref=v3.2.0"

  name      = "nginx"
  namespace = "nginx"
}
```

## Prerequisites

- A working Kubernetes cluster with the `helm` provider configured.

## Notes

- The default `name` is `"cert-manager"`, copy-pasted from another module — see DESC-01 in [../../../ISSUES.md](../../../ISSUES.md). Always set `name` explicitly.

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
| `helm_release.nginx_ingress` | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| namespace | Namespace for the cert-manager deployment | `string` | n/a | yes |
| name | The name of the cert-manager release | `string` | `"cert-manager"` | no |

<!-- END_TF_DOCS -->
