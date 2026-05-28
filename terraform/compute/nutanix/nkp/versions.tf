terraform {
  required_version = ">= 1.3"
  required_providers {
    external = {
      source  = "hashicorp/external"
      version = "~> 2.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
    nutanix = {
      source  = "nutanix/nutanix"
      version = ">= 2.4.0"
    }
  }
}
