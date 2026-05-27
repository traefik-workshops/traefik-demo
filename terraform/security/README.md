# security/

Identity providers and IAM scaffolding. The job of this section is "give the demo a working IdP with a few seeded users so the auth flow can be shown."

## Modules

| Path | Purpose |
|---|---|
| [`cognito`](./cognito) | AWS Cognito user pool + app client + seeded users |
| [`entraid`](./entraid) | Azure EntraID (Azure AD) app + users + group |
| [`keycloak/k8s`](./keycloak/k8s) | Keycloak in-cluster + realm/users |
| [`oci-instance-principal`](./oci-instance-principal) | Oracle OCI dynamic group + policy for instance principal auth |

## Picking an IdP

- **Cognito** — the demo runs on AWS and you want native federation.
- **EntraID** — the demo runs on Azure or the customer is an M365 shop.
- **Keycloak** — cloud-neutral, in-cluster; demos that need to control the IdP completely (custom claims, custom flows).
- **oci-instance-principal** — not really an IdP; just IAM scaffolding so OCI instances can talk to other OCI services without explicit creds.

## What users get seeded

All three IdP modules accept a `users` variable (list of objects). They seed those users with passwords. Today those passwords are **hardcoded** in `cognito` and `entraid` — see SEC-03 / SEC-04 in [`../../ISSUES.md`](../../ISSUES.md).

## Known issues

- Hardcoded passwords in `cognito` and `entraid` (SEC-03, SEC-04 — critical)
- `keycloak/k8s` is missing `versions.tf` (PROV-01)
