resource "k3d_cluster" "traefik_demo" {
  name = var.cluster_name
  # See https://k3d.io/v5.8.3/usage/configfile/#config-options
  k3d_config = <<EOF
apiVersion: k3d.io/v1alpha5
kind: Simple
metadata:
  name: ${var.cluster_name}
servers: ${var.control_plane_nodes.count}
agents: ${length(var.worker_nodes) == 0 ? 0 : sum([for node in var.worker_nodes : node.count])}
ports:
%{for port in var.ports~}
  - port: ${port.to}:${port.from}
    nodeFilters:
      - loadbalancer
%{endfor~}
%{if length(var.volumes) > 0~}
volumes:
%{for vol in var.volumes~}
  - volume: ${vol}
    nodeFilters:
      - all
%{endfor~}
%{endif~}
%{if length(var.host_aliases) > 0~}
hostAliases:
%{for alias in var.host_aliases~}
  - ip: ${alias.ip}
    hostnames:
%{for hostname in alias.hostnames~}
      - ${hostname}
%{endfor~}
%{endfor~}
%{endif~}
%{if length(var.registries_use) > 0 || var.registries_config != ""~}
registries:
%{if length(var.registries_use) > 0~}
  use:
%{for reg in var.registries_use~}
    - ${reg}
%{endfor~}
%{endif~}
%{if var.registries_config != ""~}
  config: |
${indent(4, "\n${var.registries_config}")}
%{endif~}
%{endif~}
options:
  k3s:
    extraArgs:
      - arg: "--disable=traefik"
        nodeFilters:
          - "server:*"
%{for node_idx, node in var.worker_nodes~}
%{if node.taint != ""~}
%{for instance in range(0, node.count)~}
      - arg: "--node-taint=node=${node.taint}:NoSchedule"
        nodeFilters:
          - agent:${node_idx > 0 ? sum([for i in range(0, node_idx) : var.worker_nodes[i].count]) + instance : instance}
%{endfor~}
%{endif~}
%{if node.label != ""~}
%{for instance in range(0, node.count)~}
      - arg: "--node-label=node=${node.label}"
        nodeFilters:
          - agent:${node_idx > 0 ? sum([for i in range(0, node_idx) : var.worker_nodes[i].count]) + instance : instance}
%{endfor~}
%{endif~}
%{endfor~}
EOF
}
