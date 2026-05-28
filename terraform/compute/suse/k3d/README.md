# compute/suse/k3d

Provisions a local k3d (k3s-in-Docker) cluster using the `SneakyBugs/k3d` provider, with configurable workers, ports, volumes, host aliases, and registry mirroring.

## Example usage

```hcl
module "k3d" {
  source = "git::https://github.com/traefik/traefik-demo.git//terraform/compute/suse/k3d?ref=v3.2.0"

  cluster_name = "demo"
}
```

## Prerequisites

- Docker installed and running locally.
- `k3d` CLI on PATH.

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name | Version |
|------|---------|
| k3d | ~> 1.0 |

## Providers

| Name | Source | Version |
|------|--------|---------|
| k3d | `SneakyBugs/k3d` | `~> 1.0` |

## Resources

| Name | Type |
|------|------|
| `k3d_cluster.traefik_demo` | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cluster_name | k3d cluster name. | `string` | n/a | yes |
| control_plane_nodes | Cluster Control Plane node config. | `object({count = number)` | `{"count":1}` | no |
| host_aliases | Entries injected into /etc/hosts on nodes and CoreDNS. | `list(object({ip = string, hostnames = list(string)))` | `[]` | no |
| ports | n/a | `list(object({from = number, to = number))` | `[{"from":80,"to":80},{"from":443,"to":443},{"from":8080,"to":8080}]` | no |
| registries_config | Contents of /etc/rancher/k3s/registries.yaml rendered into the cluster (mirrors/auth). | `string` | `""` | no |
| registries_use | Names of existing k3d-managed registries to attach to this cluster's network. | `list(string)` | `[]` | no |
| volumes | Volume mounts in 'host_path:container_path' format, applied to all nodes. | `list(string)` | `[]` | no |
| worker_nodes | Worker node config. | `list(object({label = string, taint = string, count = number))` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| client_certificate | k3d cluster client certificate |
| client_key | k3d cluster client key |
| cluster_ca_certificate | k3d cluster CA certificate |
| host | k3d cluster host |

<!-- END_TF_DOCS -->
