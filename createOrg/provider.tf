terraform {
  required_providers {
    vcd = {
      source = "vmware/vcd"
      version = "3.14.1"
    }
  }
}

provider "vcd" {
  url = var.vcd_url
  org = "System"
  user = var.vcd_username
  password = var.vcd_password
  allow_unverified_ssl = true
  auth_type = "integrated"
}