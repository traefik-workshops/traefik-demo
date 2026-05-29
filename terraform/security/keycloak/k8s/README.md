# security/keycloak/k8s

Deploys Keycloak on Kubernetes, seeds users + groups + claims, mints per-user access tokens, and stores them as Kubernetes Secrets. Optionally exposes the Keycloak UI via Traefik IngressRoute.

## Example usage

```hcl
module "keycloak" {
  source = "git::https://github.com/traefik/traefik-demo.git//terraform/security/keycloak/k8s?ref=v4.0.0"

  namespace = "security"
  users     = ["admin", "support"]
}
```

## Prerequisites

- A working Kubernetes cluster with `kubernetes`, `helm`, and `http`/`external` providers configured.
- Traefik installed in-cluster if `ingress.enabled = true`.

## Related

This module wraps the [`helm/keycloak`](../../../../helm/keycloak) chart and
adds: a `null_resource` validation gate, a Kubernetes Job that mints per-user
access tokens via the Keycloak admin API, and `kubernetes_secret_v1` resources
that publish those tokens to the cluster. Pick which:

- Use **the Helm chart directly** when the demo just needs an IdP with seeded
  realms/users/clients and you'll handle token retrieval out of band.
- Use **this Terraform module** when downstream modules need to read the
  user tokens straight from Kubernetes Secrets (the common case for the
  Hub-API-management demos in this repo).

## Notes

<!-- BEGIN_TF_DOCS -->


## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_external"></a> [external](#requirement\_external) | ~> 2.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | ~> 3.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2.27 |
| <a name="requirement_null"></a> [null](#requirement\_null) | ~> 3.2 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_external"></a> [external](#provider\_external) | ~> 2.0 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | ~> 3.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | ~> 2.27 |
| <a name="provider_null"></a> [null](#provider\_null) | ~> 3.2 |

## Resources

| Name | Type |
| ---- | ---- |
| [helm_release.keycloak](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_job_v1.fetch_tokens](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/job_v1) | resource |
| [kubernetes_secret_v1.user_tokens](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) | resource |
| [null_resource.validate_keycloak_deployment](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace for the Traefik Hub deployment | `string` | n/a | yes |
| <a name="input_users"></a> [users](#input\_users) | List of users to create in the security module | `list(string)` | n/a | yes |
| <a name="input_access_token_lifespan"></a> [access\_token\_lifespan](#input\_access\_token\_lifespan) | The lifespan of the access token in seconds | `number` | `2419200` | no |
| <a name="input_advanced_users"></a> [advanced\_users](#input\_advanced\_users) | List of advanced users with detailed configuration including groups and claims | <pre>list(object({<br/>    username = string<br/>    email    = string<br/>    password = string<br/>    groups   = list(string)<br/>    claims   = map(list(string))<br/>  }))</pre> | `[]` | no |
| <a name="input_chart"></a> [chart](#input\_chart) | Path to the Helm chart for the Keycloak deployment. When empty, uses the git-hosted chart. | `string` | `""` | no |
| <a name="input_client_certificate"></a> [client\_certificate](#input\_client\_certificate) | PEM-encoded client certificate matching `host`. Written to a temp file for the token-capture kubectl context. Required when `host` is set. | `string` | `""` | no |
| <a name="input_client_key"></a> [client\_key](#input\_client\_key) | PEM-encoded client key matching `client_certificate`. Written to a temp file for the token-capture kubectl context. Required when `host` is set. | `string` | `""` | no |
| <a name="input_domain"></a> [domain](#input\_domain) | Base domain for ingress (e.g., benchmarks.demo.traefik.ai) | `string` | `""` | no |
| <a name="input_host"></a> [host](#input\_host) | Kubernetes API server URL for the cluster Keycloak runs on. Used by the token-capture data source to build an isolated kubectl context when reading from a remote cluster. Leave empty to use the ambient kubeconfig. | `string` | `""` | no |
| <a name="input_ingress"></a> [ingress](#input\_ingress) | Ingress configuration for the keycloak service | <pre>object({<br/>    enabled    = optional(bool, false)<br/>    internal   = optional(bool, true)<br/>    domain     = optional(string, "")<br/>    entrypoint = optional(string, "traefik")<br/>  })</pre> | `{}` | no |
| <a name="input_ingress_annotations"></a> [ingress\_annotations](#input\_ingress\_annotations) | Additional metadata annotations merged onto the Ingress. Useful for custom router options beyond the three observability toggles. | `map(string)` | `{}` | no |
| <a name="input_ingress_observability"></a> [ingress\_observability](#input\_ingress\_observability) | Emit Traefik observability signals (access logs, metrics, traces) for the Keycloak ingress router. Set to false to add the three `traefik.ingress.kubernetes.io/router.observability.*: "false"` annotations. Same switch shape as other k8s modules. | `bool` | `true` | no |
| <a name="input_instances"></a> [instances](#input\_instances) | Number of Keycloak pods behind the shared Postgres backend. Scale when multiple independent test runs hit the OIDC endpoint in parallel. | `number` | `1` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of the traefik release | `string` | `"traefik"` | no |
| <a name="input_redirect_uris"></a> [redirect\_uris](#input\_redirect\_uris) | Allowed callback URL for the authentication flow | `list(string)` | `[]` | no |
| <a name="input_user_password"></a> [user\_password](#input\_user\_password) | Initial password assigned to every simple user (the `users` list). Demo default — override for anything beyond ephemeral PoCs. `advanced_users` carry their own password. The same value seeds the realm credential and is replayed by the token-fetch Job, so the two can never drift. | `string` | `"topsecretpassword"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_users"></a> [users](#output\_users) | All users with their IDs, emails, groups, and claims |
| <a name="output_users_map"></a> [users\_map](#output\_users\_map) | Map of users keyed by username |
<!-- END_TF_DOCS -->
