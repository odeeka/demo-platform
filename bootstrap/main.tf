
data "tfe_organization" "org" {
  name = "netbuild-platform"
}

resource "tfe_workspace" "bootstrap" {
  name         = "demo-platform-bootstrap"
  organization = data.tfe_organization.org.name
  tag_names    = ["platform", "bootstrap"]
}

resource "tfe_workspace" "ws_dev" {
  for_each          = toset(var.workspace)
  name              = "demo-platform-${each.value}"
  organization      = data.tfe_organization.org.name
  tag_names         = ["platform", each.value]
  working_directory = "environments/${each.value}"
}
