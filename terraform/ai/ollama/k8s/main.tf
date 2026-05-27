locals {
  m = concat(
    var.enable_qwen ? ["qwen"] : [],
    var.enable_deepseek ? ["deepseek"] : [],
    var.enable_llama ? ["llama"] : [],
  )

  qwen = var.enable_qwen ? [
    {
      name  = "ollama.models.pull[${index(local.m, "qwen") + 1}]"
      value = "qwen2.5:0.5b"
    },
    {
      name  = "ollama.models.run[${index(local.m, "qwen")}]"
      value = "qwen2.5:0.5b"
    }
  ] : []

  deepseek = var.enable_deepseek ? [
    {
      name  = "ollama.models.pull[${index(local.m, "deepseek") + 1}]"
      value = "deepseek-r1:1.5b"
    },
    {
      name  = "ollama.models.run[${index(local.m, "deepseek")}]"
      value = "deepseek-r1:1.5b"
    }
  ] : []

  llama = var.enable_llama ? [
    {
      name  = "ollama.models.pull[${index(local.m, "llama") + 1}]"
      value = "llama3.2:1b"
    },
    {
      name  = "ollama.models.run[${index(local.m, "llama")}]"
      value = "llama3.2:1b"
    }
  ] : []

  models = concat(local.qwen)
}

resource "helm_release" "ollama" {
  name       = var.name
  namespace  = var.namespace
  repository = "https://otwld.github.io/ollama-helm"
  chart      = "ollama"
  version    = "1.20.0"
  timeout    = 900
  atomic     = true

  set = concat([
    {
      name  = "ollama.models.pull[0]"
      value = "nomic-embed-text"
    },
    {
      name  = "persistentVolume.enabled"
      value = true
    }
  ], local.models)
}
