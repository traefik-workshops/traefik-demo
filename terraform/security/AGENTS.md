# Agent guide — `terraform/security/`

Inherits from [`../../AGENTS.md`](../../AGENTS.md).

## Scope

Identity providers (cognito, entraid, keycloak) and IAM scaffolding. The point is to make auth *demonstrable*.

## Modules in this section

Live-derived; regenerate with `make discover | jq '.modules[] | select(.path | startswith("terraform/security/"))'`.

| Module | Purpose |
|---|---|
| [`cognito`](./cognito) | AWS Cognito User Pool + domain + App Client + demo users. |
| [`entraid`](./entraid) | Azure AD (Entra ID) Application + client secret + demo users. |
| [`keycloak/k8s`](./keycloak/k8s) | Keycloak on Kubernetes: seeds users/groups/claims, mints per-user access tokens into Secrets, optional Traefik IngressRoute. |
| [`oci-instance-principal`](./oci-instance-principal) | OCI dynamic group + policy so compartment instances can authenticate as instance principals (no static API keys). |

## Sub-conventions

- All IdP modules accept the same `users` variable shape: `list(object({ email = string, ... }))`.
- All IdP modules expose: `user_pool_id` (or equivalent), `app_client_id`, `app_client_secret` (sensitive), `users` (with computed metadata).
- The `redirect_uris` variable accepts a list of URLs for OAuth/OIDC redirect handling.

## Required outputs

- IdP modules: `user_pool_id`, `app_client_id`, `app_client_secret` (sensitive), `users`
- Per-user passwords should be `sensitive = true` if exposed at all.

## Don't

- Don't hardcode passwords. Use a `var.<name>` (`sensitive = true`); the variable may carry a demo default so the module is zero-config, but never embed a literal credential in a `resource {}` block.
- Don't add a new IdP without checking whether Keycloak suffices. Keycloak is cloud-neutral.
- Don't bundle a *consumer* of the IdP here. The consuming demo wires up the OIDC dance itself.
