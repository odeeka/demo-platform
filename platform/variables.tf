variable "tfe_token" {
  type = string
}

variable "tenant_id" {
  type    = string
  default = "0b1af1a6-6813-47cc-9c3a-2439f3baa5f8"
}

variable "subscription_id" {
  type        = string
  default     = "a68eac86-30d9-4a8b-be2e-92df54ae5595"
  description = "pay-as-you-go-dev subscription"
}

variable "client_id" {
  type    = string
  default = "0848a1a8-9f4e-4d48-bb0e-97e1c6b88b63"
}

variable "client_secret" {
  type      = string
  sensitive = true
}

variable "location" {
  type    = string
  default = "westeurope"
}

variable "environments" {
  type    = list(string)
  default = ["dev", "test", "prod"]
}
