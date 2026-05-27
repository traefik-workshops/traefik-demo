resource "helm_release" "milvus" {
  name       = var.name
  namespace  = var.namespace
  repository = "https://zilliztech.github.io/milvus-helm"
  chart      = "milvus"
  version    = "4.2.51"
  timeout    = 900
  atomic     = true

  set = [
    {
      name  = "cluster.enabled"
      value = false
    },
    {
      name  = "etcd.replicaCount"
      value = 1
    },
    {
      name  = "etcd.persistence.size"
      value = "5Gi"
    },
    {
      name  = "pulsarv3.enabled"
      value = false
    },
    {
      name  = "minio.mode"
      value = "standalone"
    },
    {
      name  = "minio.persistence.size"
      value = "5Gi"
    },
    {
      name  = "minio.persistence.annotations.helm\\.sh\\/resource-policy"
      value = ""
    },
    {
      name  = "standalone.persistence.persistentVolumeClaim.size"
      value = "5Gi"
    },
    {
      name  = "standalone.persistence.annotations.helm\\.sh\\/resource-policy"
      value = ""
    }
  ]
}
