terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.39"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.33"
    }
    random = {
      source = "hashicorp/random"
      version = "3.4.3"
    }
  }
}

data "azuread_client_config" "current" {}

resource "azuread_application" "app" {
  display_name = "demo-platform-app-${var.name}"
  owners       = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal" "sp" {
  application_id               = azuread_application.app.application_id
  app_role_assignment_required = false
  owners                       = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal_password" "pass" {
  service_principal_id = azuread_service_principal.sp.object_id
}

output "sp_pass" {
  value     = azuread_service_principal_password.pass.value
  sensitive = true
}

output "sp_pass_key_id" {
  value     = azuread_service_principal_password.pass.key_id
}

# Application ID -> Client ID
output "client_id" {
  value = azuread_application.app.application_id
}

output "app_name" {
  value = azuread_application.app.display_name
}

output "sp_display_name" {
  value = azuread_service_principal.sp.display_name
}

output "sp_app_id" {
  value = azuread_service_principal.sp.id
}

output "sp_obj_id" {
  value = azuread_service_principal.sp.object_id
}

output "sp_name" {
  value = azuread_service_principal.sp.service_principal_names
}
