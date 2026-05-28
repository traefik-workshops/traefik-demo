module "ai_weaviate" {
  source = "../../weaviate/k8s"

  name      = "weaviate"
  namespace = var.namespace
}

module "ai_presidio" {
  source = "../../presidio/k8s"

  name      = "presidio"
  namespace = var.namespace
}

module "ai_ollama" {
  source = "../../ollama/k8s"

  name      = "ollama"
  namespace = var.namespace
}
