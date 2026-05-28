resource "nutanix_storage_containers_v2" "container" {
  name           = var.name
  cluster_ext_id = var.cluster_ext_id

  replication_factor = var.replication_factor

  # Storage optimization features
  is_inline_ec_enabled   = var.erasure_coding_enabled
  is_compression_enabled = var.compression_enabled
}
