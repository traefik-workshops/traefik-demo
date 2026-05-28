terraform {
  required_version = ">= 1.3"
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}
