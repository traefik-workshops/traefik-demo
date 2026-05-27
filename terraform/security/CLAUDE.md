# Agent guide — `terraform/security/`

Inherits from [`../../CLAUDE.md`](../../CLAUDE.md).

## Scope

Identity providers (cognito, entraid, keycloak) and IAM scaffolding. The point is to make auth *demonstrable*.

## Sub-conventions

- All IdP modules accept the same `users` variable shape: `list(object({ email = string, ... }))`.
- All IdP modules expose: `user_pool_id` (or equivalent), `app_client_id`, `app_client_secret` (sensitive), `users` (with computed metadata).
- The `redirect_uris` variable accepts a list of URLs for OAuth/OIDC redirect handling.

## Required outputs

- IdP modules: `user_pool_id`, `app_client_id`, `app_client_secret` (sensitive), `users`
- Per-user passwords should be `sensitive = true` if exposed at all.

## Don't

- Don't hardcode passwords. Use `random_password` with a `sensitive = true` output. SEC-03 / SEC-04 in [`../../ISSUES.md`](../../ISSUES.md) are blockers.
- Don't add a new IdP without checking whether Keycloak suffices. Keycloak is cloud-neutral.
- Don't bundle a *consumer* of the IdP here. The consuming demo wires up the OIDC dance itself.
