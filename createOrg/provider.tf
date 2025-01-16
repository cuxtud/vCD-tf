terraform {
  required_providers {
    vcd = {
      source = "vmware/vcd"
      version = "3.14.1"
    }
    # nsxt = {
    #   source = "vmware/nsxt"
    #   version = "~> 3.0"
    # }
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

# provider "nsxt" {
#   host = var.nsxt_host
#   user = var.nsxt_username
#   password = var.nsxt_password
#   allow_unverified_ssl = true
# }