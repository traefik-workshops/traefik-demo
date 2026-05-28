# demos/unified-ingress

The dominant real-world shape: **one transit cluster + one or more app-workload clusters**, with Traefik Hub multicluster routing through transit and OTel observability everywhere.

## What it proves

- Traefik Hub in multicluster-parent mode resolves child cluster routes.
- App-workload clusters' services are reachable through the transit cluster.
- OTel collector receives traces/metrics/access-logs from both Traefik installs.

## Install

```bash
cp terraform.tfvars.example terraform.tfvars
# edit terraform.tfvars
terraform init
terraform apply
```

Optional: install `dns-traefiker` (this repo's helm chart) for auto-DNS:

```bash
helm install dns-traefiker oci://ghcr.io/traefik-workshops/dns-traefiker --version 4.0.0 \
  --kubeconfig <(terraform output -raw app_workload_kubeconfig) \
  --set domain=${TF_VAR_domain} --set apiKey=$CLOUDFLARE_API_TOKEN
```

## Extending

- **Add more app-workload clusters** — copy the `app_workload_cluster` + `app_workload_traefik` blocks, add a new entry under `multicluster_provider.children`.
- **Add AI workload** — copy the `apps/whoami/k8s` block, swap for `ai/ollama/k8s` or similar. Or see [`../ai-gateway`](../ai-gateway).
- **Per-cluster DNS via dns-traefiker** — pass `dns_traefiker = { enabled = true, domain = ... }` on each Traefik module.

## Sourced from

This shape was extracted from sampled real demos (`aws-unified-ingress`, `k3d-unified-ingress`, `lke-unified-ingress`, `nutanix-unified-ingress`). Variations across clouds are minimal — only the `compute/<cloud>` module differs.
