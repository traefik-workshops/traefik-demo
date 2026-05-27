# Module Catalog

57 modules across: `ai/`, `compute/`, `observability/`, `security/`, `tools/`, `traefik/`, `apps/`.

## Credential requirements

| Credential | Category | Modules |
|---|---|---|
| kubeconfig only | ai/k8s, observability, tools, apps/k8s, traefik/shared | 31 modules — no cloud creds needed |
| AWS | compute/aws, security/cognito, traefik/ec2, traefik/ecs | EKS, EC2, ECS, VPC, Cognito |
| Azure | compute/azure | AKS |
| GCP | compute/gcp | GKE |
| Oracle OCI | compute/oracle, security/oci-instance-principal | OKE |
| Nutanix | compute/nutanix, traefik/nutanix, apps/whoami/nutanix | NKP, VMs, subnets |
| Akamai | compute/akamai | LKE |
| DigitalOcean | compute/digitalocean | DOKS |
| RunPod API | ai/LLMs, ai/NIMs, ai/granite-guardian, compute/runpod | GPU cloud |
| Cloudflare | tools/cloudflare | DNS |

## Deploy order (always)

```
1. compute/        → provisions cluster, outputs kubeconfig
2. traefik/        → deploys Traefik Hub (needs kubeconfig)
3. security/       → identity provider (kubeconfig or cloud creds)
4. observability/  → monitoring stack (needs kubeconfig)
5. ai/             → AI workloads (needs kubeconfig)
6. tools/          → utilities like postgresql, redis (needs kubeconfig)
7. apps/           → demo workloads (needs kubeconfig)
```

## Category reference

**compute/** — provisions Kubernetes clusters or VMs, always outputs kubeconfig
- `aws/eks` — EKS cluster. Required: `cluster_name`. Outputs: kubeconfig (host, ca_cert, token)
- `azure/aks` — AKS cluster. Required: `cluster_name`, `resource_group_name`. Outputs: kubeconfig
- `gcp/gke` — GKE cluster. Required: `cluster_name`. Outputs: kubeconfig
- `oracle/oke` — OKE cluster. Required: `cluster_name`. Outputs: kubeconfig
- `digitalocean/doks` — DOKS cluster. Required: `cluster_name`. Outputs: kubeconfig
- `akamai/lke` — LKE cluster. Required: `cluster_name`. Outputs: kubeconfig
- `suse/k3d` — local k3d cluster. All optional. Outputs: kubeconfig
- `nutanix/nkp` — NKP cluster. Required: `cluster_name`, `cluster_id`, `subnet_uuid`, `image_uuid` (15 required inputs)
- `aws/vpc`, `aws/ec2`, `aws/ecs` — AWS infra primitives
- `runpod/auth`, `runpod/pod` — GPU cloud. Required: `runpod_api_key`

**traefik/** — deploys Traefik Hub
- `k8s` (via traefik/shared) — kubeconfig only
- `ec2`, `ecs` — AWS, mostly optional inputs
- `nutanix` — Required: `vm_name`, `cluster_id`, `subnet_uuid`
- `shared` — outputs helm_values YAML, no cloud deps

**security/** — identity providers
- `keycloak/k8s` — Required: `namespace`, `users`. Outputs: user credentials. kubeconfig only
- `cognito` — AWS Cognito. No required inputs. Outputs: user_pool_id, domain
- `entraid` — Azure AD. No required inputs. Outputs: tenant_id, app_client_id
- `oci-instance-principal` — Required: `compartment_id`

**observability/** — all kubeconfig only, all require `namespace`
- `grafana/k8s`, `grafana-loki/k8s`, `grafana-stack/k8s`, `grafana-tempo/k8s`
- `prometheus/k8s`, `opentelemetry/k8s`
- `langfuse/k8s` — outputs API keys (public_key, secret_key)

**ai/** — AI/ML workloads
- k8s modules (kubeconfig only): `ollama/k8s`, `open-webui/k8s`, `milvus/k8s`, `weaviate/k8s`, `presidio/k8s`, `knative/k8s`, `23ai/k8s`, `ai-gateway-dependencies/k8s`
- RunPod modules (GPU cloud): `LLMs/runpod`, `NIMs/runpod`, `granite-guardian/runpod` — require `runpod_api_key` + model token

**tools/** — all kubeconfig only, all require `namespace`
- `postgresql/k8s` — optional: `password`, `database`
- `redis/k8s` — optional: `password`, `replicaCount`
- `argocd/k8s` — optional: `admin_password`, ingress vars
- `cert-manager/k8s`, `nginx/k8s`, `mcp-inspector/k8s`, `k6-operator/k8s`
- `cloudflare` — Required: `zone_id`, `domain`. Cloud creds: Cloudflare API token

**apps/** — sample workloads for demos
- `httpbin/k8s`, `whoami/k8s` — no required inputs
- `whoami/ec2`, `whoami/ecs` — AWS
- `whoami/nutanix` — Required: `vm_name`, `cluster_id`, `subnet_uuid`
