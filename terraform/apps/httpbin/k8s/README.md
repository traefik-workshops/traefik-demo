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

## Resources

| Name | Type |
|------|------|
| `kubernetes_deployment_v1.httpbin` | resource |
| `kubernetes_service.httpbin` | resource |

<!-- END_TF_DOCS -->
