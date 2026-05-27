# ai/ai-gateway-dependencies/k8s

Installs the in-cluster dependencies required by the AI Gateway demo (Helm-based bundle).

## Example usage

```hcl
module "aigw_deps" {
  source = "git::https://github.com/traefik/terraform-demo-modules.git//terraform/ai/ai-gateway-dependencies/k8s?ref=v3.2.0"

  namespace = "ai-gateway"
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

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| namespace | Namespace for the Grafana deployment | `string` | n/a | yes |

<!-- END_TF_DOCS -->
