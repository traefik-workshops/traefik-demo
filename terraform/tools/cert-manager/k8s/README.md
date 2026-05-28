# tools/cert-manager/k8s

Deploys cert-manager on Kubernetes via Helm.

## Example usage

```hcl
module "cert_manager" {
  source = "git::https://github.com/traefik/traefik-demo.git//terraform/tools/cert-manager/k8s?ref=v3.2.0"

  name      = "cert-manager"
  namespace = "cert-manager"
}
```

## Prerequisites

- A working Kubernetes cluster with the `helm` provider configured.

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
| `helm_release.cert_manager` | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| namespace | Namespace for the cert-manager deployment | `string` | n/a | yes |
| name | The name of the cert-manager release | `string` | `"cert-manager"` | no |

<!-- END_TF_DOCS -->
