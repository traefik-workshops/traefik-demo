# demos/oidc-portal

Traefik Hub **API Portal** behind AWS **Cognito** for OIDC. The Portal is gated; only seeded users can sign in and explore APIs.

## What it proves

- Cognito user pool + app client provision correctly.
- Traefik Hub API Management + Portal install on EKS.
- OIDC redirect flow works against the Cognito-issued client.

## Install

```bash
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform apply
# follow `cognito_app_client_id` / `_secret` outputs into the Portal config UI
```

## Swap the IdP

- **EntraID instead of Cognito** — replace `module "cognito"` with `module "entraid"` (`terraform/security/entraid`). Same `users` + `redirect_uris` shape.
- **Keycloak (in-cluster)** — replace `module "cognito"` with `module "keycloak"` (`terraform/security/keycloak/k8s`). Keycloak runs in the cluster you just provisioned — no external IdP cost.

## Sourced from

Common shape across multiple sampled client demos. The "small Azure tenant + Portal" and "AWS + Portal" patterns are the same module composition with the IdP swapped.
