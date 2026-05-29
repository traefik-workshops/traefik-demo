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
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | ~> 2.0 |

## Resources

| Name | Type |
| ---- | ---- |
| [kubernetes_deployment_v1.presidio](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/deployment_v1) | resource |
| [kubernetes_service_v1.presidio](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_v1) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_name"></a> [name](#input\_name) | Name of the Presidio Helm release. | `string` | `"presidio"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace for the Presidio Helm release. | `string` | `"presidio"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
