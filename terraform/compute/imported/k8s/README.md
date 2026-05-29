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


## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |

## Providers

No providers.

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_kubeconfig"></a> [kubeconfig](#input\_kubeconfig) | Full kubeconfig contents for the existing Kubernetes cluster. Pass via `file("~/.kube/config")` or read from a `data.local_file`. The module extracts host / CA / token from the current context (or the first context if `current-context` is unset). Sensitive. | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Logical name for the imported cluster — surfaced in outputs so downstream modules can tag resources consistently. Pure metadata; no resources are renamed based on it. | `string` | `"imported"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_cluster_ca_certificate"></a> [cluster\_ca\_certificate](#output\_cluster\_ca\_certificate) | Imported cluster CA certificate (PEM, decoded from `certificate-authority-data`). Empty when the kubeconfig uses a CA file path or exec auth — pass the CA explicitly downstream in that case. |
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | Imported cluster identifier. Mirrors `cluster_name` since there is no provider-side cluster ID for an imported cluster. |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | Imported cluster name (echo of the input, for downstream tagging). |
| <a name="output_host"></a> [host](#output\_host) | Imported cluster API server URL (parsed from kubeconfig). |
| <a name="output_kubeconfig"></a> [kubeconfig](#output\_kubeconfig) | Imported cluster kubeconfig, passed through unchanged. Use this when downstream providers can take `config_path` or a raw kubeconfig string. |
| <a name="output_token"></a> [token](#output\_token) | Imported cluster auth token (parsed from the kubeconfig's user). Empty when the kubeconfig uses exec auth — wire downstream providers via `config_path` to the kubeconfig file instead. |
<!-- END_TF_DOCS -->
