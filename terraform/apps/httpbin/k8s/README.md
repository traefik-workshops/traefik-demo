# apps/httpbin/k8s

> **Status:** stub module. Intentionally minimal; expand only if a demo needs it. Documented at this minimum scope rather than removed because demo wrappers reference it.

Deploys a minimal `httpbin` Deployment and Service in the `apps` namespace.

## Example usage

```hcl
module "httpbin" {
  source = "git::https://github.com/traefik/traefik-demo.git//terraform/apps/httpbin/k8s?ref=v4.0.0"
}
```

## Prerequisites

- A working Kubernetes cluster with the `kubernetes` provider configured.
- The `apps` namespace must exist.

## Notes

<!-- BEGIN_TF_DOCS -->


## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2.27 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | ~> 2.27 |

## Resources

| Name | Type |
| ---- | ---- |
| [kubernetes_deployment_v1.httpbin](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/deployment_v1) | resource |
| [kubernetes_service.httpbin](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service) | resource |

## Inputs

No inputs.

## Outputs

No outputs.
<!-- END_TF_DOCS -->
