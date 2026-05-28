provider "kubernetes" {
  host                   = local.cluster_server
  cluster_ca_certificate = local.cluster_ca_cert
  token                  = local.token
}

resource "kubernetes_storage_class_v1" "default" {
  metadata {
    name = "default"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }

  allow_volume_expansion = true
  storage_provisioner    = "linodebs.csi.linode.com"
  volume_binding_mode    = "Immediate"
  reclaim_policy         = "Delete"

  depends_on = [null_resource.wait]
}
