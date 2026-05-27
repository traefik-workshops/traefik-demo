terraform {
  required_version = ">= 1.3.0"
}

locals {
  granite = merge(
    var.enable_granite_guardian ? {
      granite_guardian = {
        name     = "granite-guardian"
        image    = "vllm/vllm-openai"
        tag      = "latest"
        command  = "--model ibm-granite/granite-guardian-3.3-8b"
        pod_type = var.pod_type
      }
    } : {}
  )
}

module "granite" {
  source = "../../../compute/runpod/pod"

  runpod_api_key       = var.runpod_api_key
  hugging_face_api_key = var.hugging_face_api_key
  pods                 = local.granite
}
