terraform {
  required_version = ">= 1.3"

  required_providers {
    external = {
      source  = "hashicorp/external"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.13"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.27"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }
}
