# apps/httpbin/k8s

Deploys a minimal `httpbin` Deployment and Service in the `apps` namespace.

## Example usage

```hcl
module "httpbin" {
  source = "git::https://github.com/traefik/terraform-demo-modules.git//terraform/apps/httpbin/k8s?ref=v3.2.0"
}
```

## Prerequisites

- A working Kubernetes cluster with the `kubernetes` provider configured.
- The `apps` namespace must exist.

## Notes

- This module is a stub — see STUB-01 in [../../../ISSUES.md](../../../ISSUES.md). It exposes no variables and is missing `required_providers` (PROV-01).

<!-- BEGIN_TF_DOCS -->

## Resources

| Name | Type |
|------|------|
| `kubernetes_deployment_v1.httpbin` | resource |
| `kubernetes_service.httpbin` | resource |

<!-- END_TF_DOCS -->
