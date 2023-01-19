terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.39"
    }
    tfe = {
      source  = "hashicorp/tfe"
      version = "~> 0.41"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.33"
    }
  }
}

provider "tfe" {
  # Configuration options
  token = var.tfe_token
}

provider "azurerm" {
  features {}
  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
}

module "vnet" {
  source              = "../../modules/vnet"
  vnet_name           = "demo-dev-vnet"
  location            = "westeurope"
  resource_group_name = var.rg_name
}