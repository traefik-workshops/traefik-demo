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

## Resources

| Name | Type |
|------|------|
| `helm_release.keycloak` | resource |
| `null_resource.validate_keycloak_deployment` | resource |
| `kubernetes_job_v1.fetch_tokens` | resource |
| `kubernetes_secret_v1.user_tokens` | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| namespace | Namespace for the Traefik Hub deployment | `string` | n/a | yes |
| users | List of users to create in the security module | `list(string)` | n/a | yes |
| access_token_lifespan | The lifespan of the access token in seconds | `number` | `2419200` | no |
| advanced_users | List of advanced users with detailed configuration including groups and claims | `list(object({username = string, email = string, password = string, groups = list(string), claims = map(list(string))))` | `[]` | no |
| chart | Path to the Helm chart for the Keycloak deployment. When empty, uses the git-hosted chart. | `string` | `""` | no |
| client_certificate | n/a | `string` | `""` | no |
| client_key | n/a | `string` | `""` | no |
| domain | Base domain for ingress (e.g., benchmarks.demo.traefik.ai) | `string` | `""` | no |
| host | n/a | `string` | `""` | no |
| ingress | Ingress configuration for the keycloak service | `object({enabled = optional(bool, false), internal = optional(bool, true), domain = optional(string, ""), entrypoint = optional(string, "traefik"))` | `{}` | no |
| ingress_annotations | Additional metadata annotations merged onto the Ingress. Useful for custom router options beyond the three observability toggles. | `map(string)` | `{}` | no |
| ingress_observability | Emit Traefik observability signals (access logs, metrics, traces) for the Keycloak ingress router. Set to false to add the three `traefik.ingress.kubernetes.io/router.observability.*: "false"` annotations. Same switch shape as other k8s modules. | `bool` | `true` | no |
| instances | Number of Keycloak pods behind the shared Postgres backend. Scale when multiple independent test runs hit the OIDC endpoint in parallel. | `number` | `1` | no |
| name | The name of the traefik release | `string` | `"traefik"` | no |
| redirect_uris | Allowed callback URL for the authentication flow | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| users | All users with their IDs, emails, groups, and claims |
| users_map | Map of users keyed by username |

<!-- END_TF_DOCS -->
