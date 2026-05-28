resource "azurerm_kubernetes_cluster" "traefik_demo" {
  name                = var.cluster_name
  location            = var.cluster_location
  kubernetes_version  = var.aks_version
  resource_group_name = var.resource_group_name
  dns_prefix          = replace(var.cluster_name, "_", "-")

  default_node_pool {
    name       = length(var.worker_nodes) > 0 ? substr(replace(var.worker_nodes[0].label, "-", ""), 0, 12) : "default"
    node_count = length(var.worker_nodes) > 0 ? var.worker_nodes[0].count : var.cluster_node_count
    vm_size    = var.cluster_node_type

    node_labels = length(var.worker_nodes) > 0 ? {
      node = var.worker_nodes[0].label
    } : {}

    upgrade_settings {
      drain_timeout_in_minutes      = 0
      max_surge                     = "10%"
      node_soak_duration_in_minutes = 0
    }
  }

  identity {
    type = "SystemAssigned"
  }
}

# AKS default_node_pool does not support node_taints.
# Apply the first worker_node's taint via kubectl.
resource "null_resource" "aks_default_taint" {
  count = length(var.worker_nodes) > 0 && try(length(var.worker_nodes[0].taint), 0) > 0 ? 1 : 0

  provisioner "local-exec" {
    command = <<EOT
      for node in $(kubectl get nodes -l node=${var.worker_nodes[0].label} -o name 2>/dev/null); do
        kubectl taint nodes "$node" node=${var.worker_nodes[0].taint}:NoSchedule --overwrite 2>/dev/null || true
      done
    EOT
  }

  depends_on = [azurerm_kubernetes_cluster.traefik_demo, null_resource.aks_cluster]
}

resource "azurerm_kubernetes_cluster_node_pool" "worker" {
  for_each              = length(var.worker_nodes) > 1 ? { for wn in slice(var.worker_nodes, 1, length(var.worker_nodes)) : wn.label => wn } : {}
  name                  = substr(replace(each.key, "-", ""), 0, 12)
  kubernetes_cluster_id = azurerm_kubernetes_cluster.traefik_demo.id
  vm_size               = var.cluster_node_type
  node_count            = each.value.count

  node_labels = {
    node = each.value.label
  }

  node_taints = try(length(each.value.taint), 0) > 0 ? [
    "node=${each.value.taint}:NoSchedule"
  ] : []

  upgrade_settings {
    drain_timeout_in_minutes      = 0
    max_surge                     = "10%"
    node_soak_duration_in_minutes = 0
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "traefik_demo_gpu" {
  name                  = "gpu"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.traefik_demo.id
  vm_size               = var.gpu_node_type
  node_count            = var.gpu_node_count

  node_labels = {
    accelerator = "nvidia"
  }

  node_taints = [
    "nvidia.com/gpu=true:NoSchedule"
  ]

  upgrade_settings {
    drain_timeout_in_minutes      = 0
    max_surge                     = "10%"
    node_soak_duration_in_minutes = 0
  }

  count = var.enable_gpu ? 1 : 0
}

resource "null_resource" "aks_cluster" {
  provisioner "local-exec" {
    command = <<EOT
      az aks get-credentials \
        --overwrite-existing \
        --resource-group ${var.resource_group_name} \
        --name ${var.cluster_name} \
        --context "aks-${var.cluster_name}"
      kubectl config use-context "aks-${var.cluster_name}"
    EOT
  }

  triggers = {
    always_run = timestamp()
  }

  count      = var.update_kubeconfig ? 1 : 0
  depends_on = [azurerm_kubernetes_cluster.traefik_demo, azurerm_kubernetes_cluster_node_pool.worker, azurerm_kubernetes_cluster_node_pool.traefik_demo_gpu]
}
