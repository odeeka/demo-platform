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

data "tfe_organization" "org" {
  name = "netbuild-platform"
}

data "tfe_workspace" "ws" {
  for_each     = toset(var.environments)
  name         = "demo-platform-${each.value}"
  organization = data.tfe_organization.org.name
}

resource "tfe_variable_set" "vs" {
  for_each     = toset(var.environments)
  name         = "Test Varset - ${each.value}"
  description  = "Some description."
  organization = data.tfe_organization.org.name
}

# CREATE WORKSPACE VARIABLE SETS FOR EVERY WORKSPACES
resource "tfe_workspace_variable_set" "wvs" {
  for_each        = toset(var.environments)
  workspace_id    = data.tfe_workspace.ws[each.value].id
  variable_set_id = tfe_variable_set.vs[each.value].id
}

# CREATE RESOURCE GROUPS FOR EVERY ENVIRONMENTES
resource "azurerm_resource_group" "rg" {
  for_each = toset(var.environments)
  name     = "rg-demo-platform-${each.value}"
  location = var.location
}

resource "tfe_variable" "rg_name" {
  for_each     = toset(var.environments)
  key          = "rg_name"
  value        = azurerm_resource_group.rg[each.value].name
  category     = "terraform"
  workspace_id = data.tfe_workspace.ws[each.value].id
  description  = "${each.value} resource group"
}

# GLOBAL ADMIN MUST BE SET TO THE RUNNER SPI
module "spi" {
  for_each = toset(var.environments)
  source   = "../modules/spi"
  name     = each.value
  test = "test"
}

resource "tfe_variable" "client_secret" {
  for_each     = toset(var.environments)
  key          = "client_secret"
  value        = module.spi[each.value].sp_pass
  category     = "terraform"
  workspace_id = data.tfe_workspace.ws[each.value].id
  description  = "${each.value} client secret"
  sensitive    = true
}

resource "tfe_variable" "client_secret_key_id" {
  for_each     = toset(var.environments)
  key          = "client_secret_key_id"
  value        = module.spi[each.value].sp_pass_key_id
  category     = "terraform"
  workspace_id = data.tfe_workspace.ws[each.value].id
  description  = "${each.value} client secret key id"
  sensitive    = false
}

resource "tfe_variable" "client_id" {
  for_each     = toset(var.environments)
  key          = "client_id"
  value        = module.spi[each.value].client_id
  category     = "terraform"
  workspace_id = data.tfe_workspace.ws[each.value].id
  description  = "${each.value} application id"
}

resource "tfe_variable" "subscription_id" {
  for_each     = toset(var.environments)
  key          = "subscription_id"
  value        = var.subscription_id
  category     = "terraform"
  workspace_id = data.tfe_workspace.ws[each.value].id
  description  = "${each.value} subscription id"
}

resource "tfe_variable" "tenant_id" {
  for_each     = toset(var.environments)
  key          = "tenant_id"
  value        = var.tenant_id
  category     = "terraform"
  workspace_id = data.tfe_workspace.ws[each.value].id
  description  = "${each.value} tenant id"
}

data "azurerm_subscription" "sub" {
  subscription_id = var.subscription_id
}

resource "azurerm_role_assignment" "sub_reader" {
  for_each             = toset(var.environments)
  scope                = data.azurerm_subscription.sub.id
  role_definition_name = "Reader"
  principal_id         = module.spi[each.value].sp_obj_id
}

resource "azurerm_role_assignment" "owner" {
  for_each             = toset(var.environments)
  scope                = azurerm_resource_group.rg[each.value].id
  role_definition_name = "Owner"
  principal_id         = module.spi[each.value].sp_obj_id
}