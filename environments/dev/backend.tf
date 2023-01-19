terraform {
  cloud {
    organization = "netbuild-platform"

    workspaces {
      name = "demo-platform-dev"
    }
  }
}

output "rg" {
  value = var.rg_name
}