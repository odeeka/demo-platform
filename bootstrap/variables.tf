variable "tfe_token" {
  type      = string
  sensitive = true
}

variable "workspace" {
  type    = list(string)
  default = ["dev", "test", "prod"]
}