# compute/imported/k8s

Bring-your-own Kubernetes cluster: adapt an existing cluster's kubeconfig to the same output shape this repo's managed-k8s modules expose (EKS, AKS, DOKS, ...). Downstream modules (observability, traefik, ai, security, tools) can then consume the imported cluster with no changes to their inputs.

Provisions nothing.

## When to use

- A customer demo against the customer's existing cluster.
- QA / support spinning up a workload against a long-lived test cluster.
- Local development against a kind / k3d / Docker Desktop cluster you don't want to manage from this repo.

## Example usage

```hcl
module "cluster" {
  source = "git::https://github.com/traefik/traefik-demo.git//terraform/compute/imported/k8s?ref=v4.0.0"

  kubeconfig   = file("~/.kube/config")
  cluster_name = "acme-prod-eu"
}

module "traefik" {
  source = "git::https://github.com/traefik/traefik-demo.git//terraform/traefik/k8s?ref=v4.0.0"

  host                   = module.cluster.host
  cluster_ca_certificate = module.cluster.cluster_ca_certificate
  token                  = module.cluster.token
  # ...
}
```

## Extracting fields from an existing kubeconfig

If you don't already have a single-context kubeconfig, narrow yours first:

```bash
kubectl config view --raw --minify --flatten > /tmp/kubeconfig.yaml
```

Then pass `file("/tmp/kubeconfig.yaml")` as `kubeconfig`.

## Auth modes — what works

| kubeconfig user shape | `host` | `cluster_ca_certificate` | `token` | `kubeconfig` |
|---|---|---|---|---|
| Static token (`user.token`) | ✅ | ✅ | ✅ | ✅ |
| Client cert + key (`user.client-certificate-data` + `user.client-key-data`) | ✅ | ✅ | ❌ (empty) | ✅ |
| Exec plugin (`user.exec`, e.g. EKS/GKE) | ✅ | ✅ | ❌ (empty) | ✅ |

For non-token auth modes, downstream `helm` / `kubernetes` providers must be wired via `config_path = "/path/to/kubeconfig.yaml"` rather than `host + token`. Write the kubeconfig to disk and pass the path; the exec plugin runs at apply time.

## Not handled

- `certificate-authority` (file path) — only `certificate-authority-data` (base64) is parsed. Use `kubectl config view --raw --flatten` to inline the CA into the kubeconfig before passing.
- Multiple contexts where you want a non-default one — set `current-context` in the kubeconfig before passing, or use `kubectl config view --minify` to drop the others.

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
