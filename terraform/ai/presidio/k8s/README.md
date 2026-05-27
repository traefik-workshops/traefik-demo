# ai/presidio/k8s

Deploys Microsoft Presidio (PII detection / anonymization) into a Kubernetes cluster via Helm.

## Example usage

```hcl
module "presidio" {
  source = "git::https://github.com/traefik/terraform-demo-modules.git//terraform/ai/presidio/k8s?ref=v3.2.0"

  name      = "presidio"
  namespace = "presidio"
}
```

## Prerequisites

- A working Kubernetes cluster with the `helm` provider configured.

## Notes

- Variable defaults/descriptions still reference Milvus — see DESC-01 in [../../../ISSUES.md](../../../ISSUES.md).

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
| `kubernetes_deployment_v1.presidio` | resource |
| `kubernetes_service_v1.presidio` | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | The name of the milvus release | `string` | `"milvus"` | no |
| namespace | The namespace of the milvus release | `string` | `"milvus"` | no |

<!-- END_TF_DOCS -->
