# compute/suse/k3d

Provisions a local k3d (k3s-in-Docker) cluster using the `SneakyBugs/k3d` provider, with configurable workers, ports, volumes, host aliases, and registry mirroring.

## Example usage

```hcl
module "k3d" {
  source = "git::https://github.com/traefik/traefik-demo.git//terraform/compute/suse/k3d?ref=v4.0.0"

  cluster_name = "demo"
}
```

## Prerequisites

- Docker installed and running locally.
- `k3d` CLI on PATH.

<!-- BEGIN_TF_DOCS -->


## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_k3d"></a> [k3d](#requirement\_k3d) | ~> 1.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_k3d"></a> [k3d](#provider\_k3d) | ~> 1.0 |

## Resources

| Name | Type |
| ---- | ---- |
| [k3d_cluster.traefik_demo](https://registry.terraform.io/providers/SneakyBugs/k3d/latest/docs/resources/cluster) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | k3d cluster name. | `string` | n/a | yes |
| <a name="input_control_plane_nodes"></a> [control\_plane\_nodes](#input\_control\_plane\_nodes) | Cluster Control Plane node config. | <pre>object({<br/>    count = number<br/>  })</pre> | <pre>{<br/>  "count": 1<br/>}</pre> | no |
| <a name="input_host_aliases"></a> [host\_aliases](#input\_host\_aliases) | Entries injected into /etc/hosts on nodes and CoreDNS. | <pre>list(object({<br/>    ip        = string<br/>    hostnames = list(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_ports"></a> [ports](#input\_ports) | Host→cluster port mappings exposed by the k3d load balancer. Default opens 80/443 (HTTP/HTTPS) and 8080 (Traefik dashboard) on the host. Add entries for any extra ingress ports the demo needs. | <pre>list(object({<br/>    from = number<br/>    to   = number<br/>  }))</pre> | <pre>[<br/>  {<br/>    "from": 80,<br/>    "to": 80<br/>  },<br/>  {<br/>    "from": 443,<br/>    "to": 443<br/>  },<br/>  {<br/>    "from": 8080,<br/>    "to": 8080<br/>  }<br/>]</pre> | no |
| <a name="input_registries_config"></a> [registries\_config](#input\_registries\_config) | Contents of /etc/rancher/k3s/registries.yaml rendered into the cluster (mirrors/auth). | `string` | `""` | no |
| <a name="input_registries_use"></a> [registries\_use](#input\_registries\_use) | Names of existing k3d-managed registries to attach to this cluster's network. | `list(string)` | `[]` | no |
| <a name="input_volumes"></a> [volumes](#input\_volumes) | Volume mounts in 'host\_path:container\_path' format, applied to all nodes. | `list(string)` | `[]` | no |
| <a name="input_worker_nodes"></a> [worker\_nodes](#input\_worker\_nodes) | Worker node pools to create. Each entry sizes one pool with `count` agents and applies the given Kubernetes `label` and `taint`. Default `[]` runs control-plane-only — fine for small demos. | <pre>list(object({<br/>    label = string<br/>    taint = string<br/>    count = number<br/>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_client_certificate"></a> [client\_certificate](#output\_client\_certificate) | k3d cluster client certificate |
| <a name="output_client_key"></a> [client\_key](#output\_client\_key) | k3d cluster client key |
| <a name="output_cluster_ca_certificate"></a> [cluster\_ca\_certificate](#output\_cluster\_ca\_certificate) | k3d cluster CA certificate |
| <a name="output_host"></a> [host](#output\_host) | k3d cluster host |
<!-- END_TF_DOCS -->
