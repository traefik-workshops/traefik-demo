terraform {
  required_version = ">= 1.3.0"
}

locals {
  llms = merge(
    var.enable_llama31_8b ? {
      Llama31_8b = {
        name     = "Meta-Llama-3.1-8B-Instruct"
        image    = "vllm/vllm-openai"
        tag      = "latest"
        command  = "--host 0.0.0.0 --port 8000 --model meta-llama/Meta-Llama-3.1-8B-Instruct --dtype bfloat16 --enforce-eager --gpu-memory-utilization 0.95"
        pod_type = var.pod_type
      }
      } : {}, var.enable_gpt_oss_20b ? {
      gpt_oss_20b = {
        name     = "gpt-oss-20b"
        image    = "vllm/vllm-openai"
        tag      = "latest"
        command  = "--model openai/gpt-oss-20b"
        pod_type = var.pod_type
      }
    } : {}
  )
}

module "llms" {
  source = "../../../compute/runpod/pod"

  runpod_api_key       = var.runpod_api_key
  hugging_face_api_key = var.hugging_face_api_key
  pods                 = local.llms
}
