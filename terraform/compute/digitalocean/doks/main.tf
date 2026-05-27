resource "digitalocean_kubernetes_cluster" "traefik_demo" {
  name    = var.cluster_name
  region  = var.cluster_location
  version = var.doks_version

  node_pool {
    name       = length(var.worker_nodes) > 0 ? "${var.cluster_name}-${var.worker_nodes[0].label}" : "default"
    size       = var.cluster_node_type
    node_count = length(var.worker_nodes) > 0 ? var.worker_nodes[0].count : var.cluster_node_count
    auto_scale = length(var.worker_nodes) > 0 ? false : var.enable_autoscaling
    min_nodes  = length(var.worker_nodes) > 0 ? null : var.min_nodes
    max_nodes  = length(var.worker_nodes) > 0 ? null : var.max_nodes

    labels = length(var.worker_nodes) > 0 ? {
      node = var.worker_nodes[0].label
    } : {}

    dynamic "taint" {
      for_each = length(var.worker_nodes) > 0 && try(length(var.worker_nodes[0].taint), 0) > 0 ? [var.worker_nodes[0]] : []
      content {
        key    = "node"
        value  = taint.value.taint
        effect = "NoSchedule"
      }
    }
  }
}

resource "digitalocean_kubernetes_node_pool" "worker" {
  for_each   = length(var.worker_nodes) > 1 ? { for wn in slice(var.worker_nodes, 1, length(var.worker_nodes)) : wn.label => wn } : {}
  cluster_id = digitalocean_kubernetes_cluster.traefik_demo.id
  name       = "${var.cluster_name}-${each.key}"
  size       = var.cluster_node_type
  node_count = each.value.count

  labels = {
    node = each.value.label
  }

  dynamic "taint" {
    for_each = try(length(each.value.taint), 0) > 0 ? [each.value.taint] : []
    content {
      key    = "node"
      value  = taint.value
      effect = "NoSchedule"
    }
  }
}

resource "null_resource" "wait" {
  depends_on = [digitalocean_kubernetes_cluster.traefik_demo, digitalocean_kubernetes_node_pool.worker]

  provisioner "local-exec" {
    command = <<EOF
    sleep 30
    EOF
  }
}

resource "null_resource" "doks_cluster" {
  provisioner "local-exec" {
    command = <<EOT
      echo '${digitalocean_kubernetes_cluster.traefik_demo.kube_config.0.raw_config}' > doks-kubeconfig.yaml

      export KUBECONFIG=~/.kube/config:doks-kubeconfig.yaml
      kubectl config view --flatten > merged.yaml
      mv merged.yaml ~/.kube/config

      kubectl config delete-context "doks-${var.cluster_name}" 2>/dev/null || true
      kubectl config rename-context "do-${var.cluster_location}-${var.cluster_name}" "doks-${var.cluster_name}"
      kubectl config use-context "doks-${var.cluster_name}"

      rm doks-kubeconfig.yaml
    EOT
  }

  triggers = {
    always_run = timestamp()
  }

  count      = var.update_kubeconfig ? 1 : 0
  depends_on = [null_resource.wait]
}
