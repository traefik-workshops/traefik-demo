# ai/milvus/k8s

Deploys the Milvus vector database into a Kubernetes cluster via Helm.

## Example usage

```hcl
module "milvus" {
  source = "git::https://github.com/traefik/traefik-demo.git//terraform/ai/milvus/k8s?ref=v4.0.0"

  namespace = "milvus"
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
| `helm_release.milvus` | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| namespace | The namespace of the milvus release | `string` | n/a | yes |
| name | The name of the milvus release | `string` | `"milvus"` | no |

<!-- END_TF_DOCS -->
