terraform {
  required_providers {
    tfe = {
      source  = "hashicorp/tfe"
      version = "~> 0.41"
    }
  }
}

provider "tfe" {
  # Configuration options
  token = var.tfe_token
}