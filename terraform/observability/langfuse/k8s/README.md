# observability/langfuse/k8s

Deploys Langfuse (LLM observability) on Kubernetes via the `langfuse/langfuse-k8s` Helm chart, with headless org/project/admin seeding and an optional Traefik IngressRoute.

## Example usage

```hcl
module "langfuse" {
  source = "git::https://github.com/traefik/traefik-demo.git//terraform/observability/langfuse/k8s?ref=v4.0.0"

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
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_helm"></a> [helm](#provider\_helm) | >= 2.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >= 2.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.0 |

## Resources

| Name | Type |
| ---- | ---- |
| [helm_release.langfuse](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_manifest.ingressroute](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [random_string.public_key_suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [random_string.secret_key_suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_chart_version"></a> [chart\_version](#input\_chart\_version) | Version of the langfuse/langfuse-k8s Helm chart. | `string` | `"1.5.27"` | no |
| <a name="input_disable_signup"></a> [disable\_signup](#input\_disable\_signup) | When true, sets AUTH\_DISABLE\_SIGNUP=true so no additional users can register after the seeded admin. | `bool` | `true` | no |
| <a name="input_encryption_key"></a> [encryption\_key](#input\_encryption\_key) | ENCRYPTION\_KEY for at-rest encryption (langfuse.encryptionKey.value). 64 hex chars. Demo default is all zeros — override for real use (openssl rand -hex 32). | `string` | `"0000000000000000000000000000000000000000000000000000000000000000"` | no |
| <a name="input_ingress"></a> [ingress](#input\_ingress) | Create a Traefik IngressRoute on `ingress_host` pointing at the langfuse-web Service. | `bool` | `false` | no |
| <a name="input_ingress_annotations"></a> [ingress\_annotations](#input\_ingress\_annotations) | Additional metadata annotations merged onto the IngressRoute. Useful for custom router options beyond the three observability toggles. | `map(string)` | `{}` | no |
| <a name="input_ingress_entrypoint"></a> [ingress\_entrypoint](#input\_ingress\_entrypoint) | Traefik entrypoint the IngressRoute binds to. | `string` | `"web"` | no |
| <a name="input_ingress_external_port"></a> [ingress\_external\_port](#input\_ingress\_external\_port) | External port on which `ingress_host` is reachable from a browser — used only to build the NEXTAUTH\_URL. | `number` | `8080` | no |
| <a name="input_ingress_host"></a> [ingress\_host](#input\_ingress\_host) | Host header matched by the IngressRoute (when ingress=true). | `string` | `"langfuse.localhost"` | no |
| <a name="input_ingress_observability"></a> [ingress\_observability](#input\_ingress\_observability) | Emit Traefik observability signals (access logs, metrics, traces) for the Langfuse UI router. Set to false to add the three `traefik.ingress.kubernetes.io/router.observability.*: "false"` annotations. Same switch shape as other observability/k8s modules. | `bool` | `true` | no |
| <a name="input_init_org_id"></a> [init\_org\_id](#input\_init\_org\_id) | Identifier of the seeded organization (LANGFUSE\_INIT\_ORG\_ID). | `string` | `"default"` | no |
| <a name="input_init_org_name"></a> [init\_org\_name](#input\_init\_org\_name) | Display name of the seeded organization (LANGFUSE\_INIT\_ORG\_NAME). | `string` | `"Demo"` | no |
| <a name="input_init_project_id"></a> [init\_project\_id](#input\_init\_project\_id) | Identifier of the seeded project (LANGFUSE\_INIT\_PROJECT\_ID). | `string` | `"default"` | no |
| <a name="input_init_project_name"></a> [init\_project\_name](#input\_init\_project\_name) | Display name of the seeded project (LANGFUSE\_INIT\_PROJECT\_NAME). | `string` | `"default"` | no |
| <a name="input_init_user_email"></a> [init\_user\_email](#input\_init\_user\_email) | Email of the seeded admin user. Used to log into the UI (LANGFUSE\_INIT\_USER\_EMAIL). Langfuse requires a valid email; the local-part is what users type as the login handle. | `string` | `"admin@traefik.io"` | no |
| <a name="input_init_user_name"></a> [init\_user\_name](#input\_init\_user\_name) | Display name of the seeded admin user (LANGFUSE\_INIT\_USER\_NAME). | `string` | `"Admin"` | no |
| <a name="input_init_user_password"></a> [init\_user\_password](#input\_init\_user\_password) | Password of the seeded admin user (LANGFUSE\_INIT\_USER\_PASSWORD). Demo default; override for anything real. DEMO DEFAULT — override per environment. | `string` | `"topsecretpassword"` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the langfuse release. | `string` | `"langfuse"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace of the langfuse release. Caller is expected to create it. Default matches the opentelemetry/k8s module so collector + langfuse can live side by side. | `string` | `"traefik-observability"` | no |
| <a name="input_nextauth_secret"></a> [nextauth\_secret](#input\_nextauth\_secret) | NEXTAUTH\_SECRET (langfuse.nextauth.secret.value). Demo default — rotate for real use. | `string` | `"demo-nextauth-secret-change-me"` | no |
| <a name="input_replicas"></a> [replicas](#input\_replicas) | Replica count for langfuse web and worker deployments. | `number` | `1` | no |
| <a name="input_salt"></a> [salt](#input\_salt) | SALT used to hash API keys (langfuse.salt.value). Demo default — rotate for real use. | `string` | `"demo-salt-change-me"` | no |
| <a name="input_subchart_password"></a> [subchart\_password](#input\_subchart\_password) | Shared password for the bundled Postgres, Redis, Clickhouse, and S3 (Minio) subcharts. Demo convenience. | `string` | `"langfuse"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_admin_user_email"></a> [admin\_user\_email](#output\_admin\_user\_email) | Email of the seeded admin user — UI login. |
| <a name="output_admin_user_password"></a> [admin\_user\_password](#output\_admin\_user\_password) | Password of the seeded admin user — UI login. |
| <a name="output_otel_endpoint"></a> [otel\_endpoint](#output\_otel\_endpoint) | In-cluster OTLP base URL. Append nothing — the OTel exporter handles /v1/traces itself. |
| <a name="output_public_key"></a> [public\_key](#output\_public\_key) | Seeded Langfuse public API key (pk-lf-…). Wire into the OTel Collector's langfuse exporter. |
| <a name="output_secret_key"></a> [secret\_key](#output\_secret\_key) | Seeded Langfuse secret API key (sk-lf-…). |
| <a name="output_web_service_name"></a> [web\_service\_name](#output\_web\_service\_name) | Service name of the langfuse-web component. Pair with `namespace` to build in-cluster DNS. |
<!-- END_TF_DOCS -->
