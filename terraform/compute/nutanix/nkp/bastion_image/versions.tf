terraform {
  required_version = ">= 1.3"
  required_providers {
    nutanix = {
      source  = "nutanix/nutanix"
      version = ">= 2.4.0"
    }
  }
}
