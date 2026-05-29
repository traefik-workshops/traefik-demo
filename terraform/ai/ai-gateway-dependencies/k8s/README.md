# ai/ai-gateway-dependencies/k8s

Installs the in-cluster dependencies required by the AI Gateway demo (Helm-based bundle).

## Example usage

```hcl
module "aigw_deps" {
  source = "git::https://github.com/traefik/traefik-demo.git//terraform/ai/ai-gateway-dependencies/k8s?ref=v4.0.0"

  namespace = "ai-gateway"
}
```

## Prerequisites

- A working Kubernetes cluster with the `helm` provider configured.

<!-- BEGIN_TF_DOCS -->


## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |

## Providers

No providers.

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace for the Grafana deployment | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
