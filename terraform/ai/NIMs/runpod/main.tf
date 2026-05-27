terraform {
  required_version = ">= 1.3.0"
}

locals {
  nims = merge(
    var.enable_topic_control_nim ? {
      topic_control = {
        name     = "topic-control-nim"
        image    = "nvcr.io/nim/nvidia/llama-3.1-nemoguard-8b-topic-control"
        tag      = "latest"
        command  = ""
        pod_type = var.pod_type
      }
    } : {},
    var.enable_content_safety_nim ? {
      content_safety = {
        name     = "content-safety-nim"
        image    = "nvcr.io/nim/nvidia/llama-3.1-nemoguard-8b-content-safety"
        tag      = "latest"
        command  = ""
        pod_type = var.pod_type
      }
    } : {},
    var.enable_jailbreak_detection_nim ? {
      jailbreak_detection = {
        name     = "jailbreak-detection-nim"
        image    = "nvcr.io/nim/nvidia/nemoguard-jailbreak-detect"
        tag      = "latest"
        command  = ""
        pod_type = var.pod_type
      }
    } : {}
  )
}

module "auth" {
  source = "../../../compute/runpod/auth"

  runpod_api_key = var.runpod_api_key
  ngc_token      = var.ngc_token
  ngc_username   = var.ngc_username
}

module "nims" {
  source = "../../../compute/runpod/pod"

  runpod_api_key   = var.runpod_api_key
  ngc_token        = var.ngc_token
  pods             = local.nims
  registry_auth_id = module.auth.registry_auth_id
}
