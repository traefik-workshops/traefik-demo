# ai/presidio/k8s

Deploys Microsoft Presidio (PII detection / anonymization) into a Kubernetes cluster via Helm.

## Example usage

```hcl
module "presidio" {
  source = "git::https://github.com/traefik/traefik-demo.git//terraform/ai/presidio/k8s?ref=v4.0.0"

  name      = "presidio"
  namespace = "presidio"
}
```

## Prerequisites

- A working Kubernetes cluster with the `helm` provider configured.

## Related

There is also a Helm chart that ships Presidio with the full values surface:
[`helm/presidio`](../../../../helm/presidio). Pick which:

- Use **the Helm chart** when the demo runs Presidio with non-default
  resource requests/limits, custom image tags, or is consumed by another
  chart (notably the umbrella `ai-gateway` chart pulls it in as a subchart).
- Use **this Terraform module** for the trivial in-Terraform demo case —
  it stands up a single Deployment + Service with hardcoded image and
  resources. Extend with the chart if you need real knobs.

## Notes

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
