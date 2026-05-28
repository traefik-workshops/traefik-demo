resource "linode_lke_cluster" "traefik_demo" {
  label       = var.cluster_name
  region      = var.cluster_location
  k8s_version = var.lke_version

  control_plane {
    high_availability = var.control_plane_high_availability
  }

  # When worker_nodes is empty, create a single default pool.
  # When worker_nodes is set, create per-role pools instead.
  dynamic "pool" {
    for_each = length(var.worker_nodes) == 0 ? ["default"] : []
    content {
      type   = var.cluster_node_type
      count  = var.cluster_node_count
      labels = var.node_labels
    }
  }

  dynamic "pool" {
    for_each = var.worker_nodes
    content {
      type  = var.cluster_node_type
      count = pool.value.count

      labels = {
        node = pool.value.label
      }

      dynamic "taint" {
        for_each = try(length(pool.value.taint), 0) > 0 ? [pool.value.taint] : []
        content {
          key    = "node"
          value  = taint.value
          effect = "NoSchedule"
        }
      }
    }
  }

  dynamic "pool" {
    for_each = var.enable_gpu ? ["gpu"] : []
    content {
      type   = var.gpu_node_type
      count  = var.gpu_node_count
      labels = var.node_labels
    }
  }
}

resource "null_resource" "wait" {
  depends_on = [linode_lke_cluster.traefik_demo]

  provisioner "local-exec" {
    command = <<EOF
    sleep 30
    EOF
  }
}

resource "null_resource" "lke_cluster" {
  provisioner "local-exec" {

    command = <<EOT
      TMPKUBE=/tmp/lke-kubeconfig-${var.cluster_name}.yaml
      TMPMERGE=/tmp/lke-merged-${var.cluster_name}.yaml
      LOCKDIR=/tmp/lke-kubeconfig-merge.lock
      echo '${local.kubeconfig_raw}' > "$TMPKUBE"

      while ! mkdir "$LOCKDIR" 2>/dev/null; do sleep 0.5; done
      trap "rm -rf '$LOCKDIR'" EXIT

      export KUBECONFIG=~/.kube/config:"$TMPKUBE"
      kubectl config view --flatten > "$TMPMERGE"
      mv "$TMPMERGE" ~/.kube/config

      rm -rf "$LOCKDIR"

      kubectl config delete-context "${var.cluster_name_prefix}${var.cluster_name}" 2>/dev/null || true
      kubectl config rename-context "lke${linode_lke_cluster.traefik_demo.id}-ctx" "${var.cluster_name_prefix}${var.cluster_name}"
      kubectl config use-context "${var.cluster_name_prefix}${var.cluster_name}"

      rm "$TMPKUBE"
    EOT
  }

  triggers = {
    always_run = timestamp()
  }

  count      = var.update_kubeconfig ? 1 : 0
  depends_on = [null_resource.wait]
}
