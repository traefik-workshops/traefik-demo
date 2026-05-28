# observability/langfuse/k8s

Deploys Langfuse (LLM observability) on Kubernetes via the `langfuse/langfuse-k8s` Helm chart, with headless org/project/admin seeding and an optional Traefik IngressRoute.

## Example usage

```hcl
module "langfuse" {
  source = "git::https://github.com/traefik/traefik-demo.git//terraform/observability/langfuse/k8s?ref=v3.2.0"

  name      = "langfuse"
  namespace = "traefik-observability"
}
```

## Prerequisites

- A working Kubernetes cluster with `helm`, `kubernetes`, and `random` providers configured.
- Traefik installed in-cluster if `ingress = true`.

## Notes

- All crypto defaults (`nextauth_secret`, `salt`, `encryption_key`, `subchart_password`, `init_user_password`) are demo values — rotate for anything real.

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name | Version |
|------|---------|
| helm | >= 2.0 |
| kubernetes | >= 2.0 |
| random | >= 3.0 |

## Providers

| Name | Source | Version |
|------|--------|---------|
| helm | `hashicorp/helm` | `>= 2.0` |
| kubernetes | `hashicorp/kubernetes` | `>= 2.0` |
| random | `hashicorp/random` | `>= 3.0` |

## Resources

| Name | Type |
|------|------|
| `random_string.public_key_suffix` | resource |
| `random_string.secret_key_suffix` | resource |
| `helm_release.langfuse` | resource |
| `kubernetes_manifest.ingressroute` | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| chart_version | Version of the langfuse/langfuse-k8s Helm chart. | `string` | `"1.5.27"` | no |
| disable_signup | When true, sets AUTH_DISABLE_SIGNUP=true so no additional users can register after the seeded admin. | `bool` | `true` | no |
| encryption_key 🔒 | ENCRYPTION_KEY for at-rest encryption (langfuse.encryptionKey.value). 64 hex chars. Demo default is all zeros — override for real use (openssl rand -hex 32). | `string` | `"0000000000000000000000000000000000000000000000000000000000000000"` | no |
| ingress | Create a Traefik IngressRoute on `ingress_host` pointing at the langfuse-web Service. | `bool` | `false` | no |
| ingress_annotations | Additional metadata annotations merged onto the IngressRoute. Useful for custom router options beyond the three observability toggles. | `map(string)` | `{}` | no |
| ingress_entrypoint | Traefik entrypoint the IngressRoute binds to. | `string` | `"web"` | no |
| ingress_external_port | External port on which `ingress_host` is reachable from a browser — used only to build the NEXTAUTH_URL. | `number` | `8080` | no |
| ingress_host | Host header matched by the IngressRoute (when ingress=true). | `string` | `"langfuse.localhost"` | no |
| ingress_observability | Emit Traefik observability signals (access logs, metrics, traces) for the Langfuse UI router. Set to false to add the three `traefik.ingress.kubernetes.io/router.observability.*: "false"` annotations. Same switch shape as other observability/k8s modules. | `bool` | `true` | no |
| init_org_id | Identifier of the seeded organization (LANGFUSE_INIT_ORG_ID). | `string` | `"default"` | no |
| init_org_name | Display name of the seeded organization (LANGFUSE_INIT_ORG_NAME). | `string` | `"Demo"` | no |
| init_project_id | Identifier of the seeded project (LANGFUSE_INIT_PROJECT_ID). | `string` | `"default"` | no |
| init_project_name | Display name of the seeded project (LANGFUSE_INIT_PROJECT_NAME). | `string` | `"default"` | no |
| init_user_email | Email of the seeded admin user. Used to log into the UI (LANGFUSE_INIT_USER_EMAIL). Langfuse requires a valid email; the local-part is what users type as the login handle. | `string` | `"admin@traefik.io"` | no |
| init_user_name | Display name of the seeded admin user (LANGFUSE_INIT_USER_NAME). | `string` | `"Admin"` | no |
| init_user_password 🔒 | Password of the seeded admin user (LANGFUSE_INIT_USER_PASSWORD). Demo default; override for anything real. | `string` | `"topsecretpassword"` | no |
| name | Name of the langfuse release. | `string` | `"langfuse"` | no |
| namespace | Namespace of the langfuse release. Caller is expected to create it. Default matches the opentelemetry/k8s module so collector + langfuse can live side by side. | `string` | `"traefik-observability"` | no |
| nextauth_secret 🔒 | NEXTAUTH_SECRET (langfuse.nextauth.secret.value). Demo default — rotate for real use. | `string` | `"demo-nextauth-secret-change-me"` | no |
| replicas | Replica count for langfuse web and worker deployments. | `number` | `1` | no |
| salt 🔒 | SALT used to hash API keys (langfuse.salt.value). Demo default — rotate for real use. | `string` | `"demo-salt-change-me"` | no |
| subchart_password 🔒 | Shared password for the bundled Postgres, Redis, Clickhouse, and S3 (Minio) subcharts. Demo convenience. | `string` | `"langfuse"` | no |

## Outputs

| Name | Description |
|------|-------------|
| admin_user_email | Email of the seeded admin user — UI login. |
| admin_user_password 🔒 | Password of the seeded admin user — UI login. |
| otel_endpoint | In-cluster OTLP base URL. Append nothing — the OTel exporter handles /v1/traces itself. |
| public_key 🔒 | Seeded Langfuse public API key (pk-lf-…). Wire into the OTel Collector's langfuse exporter. |
| secret_key 🔒 | Seeded Langfuse secret API key (sk-lf-…). |
| web_service_name | Service name of the langfuse-web component. Pair with `namespace` to build in-cluster DNS. |

<!-- END_TF_DOCS -->
