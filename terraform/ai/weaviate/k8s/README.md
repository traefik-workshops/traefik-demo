# ai/weaviate/k8s

Deploys the Weaviate vector database into a Kubernetes cluster via Helm.

## Example usage

```hcl
module "weaviate" {
  source = "git::https://github.com/traefik/terraform-demo-modules.git//terraform/ai/weaviate/k8s?ref=v3.2.0"

  namespace = "weaviate"
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
| `helm_release.weaviate` | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| namespace | The namespace of the weaviate release | `string` | n/a | yes |
| name | The name of the weaviate release | `string` | `"weaviate"` | no |

<!-- END_TF_DOCS -->
