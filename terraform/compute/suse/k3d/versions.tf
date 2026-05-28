terraform {
  required_version = ">= 1.3"
  required_providers {
    k3d = {
      source  = "SneakyBugs/k3d"
      version = "~> 1.0"
    }
  }
}
