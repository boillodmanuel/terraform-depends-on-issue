terraform {
  required_version = ">= 1.0"
  backend "local" {
    path = "backend/terraform.tfstate"
  }
  required_providers {
    kubectl = {
      source  = "alekc/kubectl"
      version = "~> 2.0"
    }
  }
}