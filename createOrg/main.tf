# resource "vcd_org" "my-org" {
#   name             = "my-org"
#   full_name        = "My organization"
#   description      = "The pride of my work"
#   is_enabled       = true
#   delete_recursive = true
#   delete_force     = true
#   deployed_vm_quota = 10
#   stored_vm_quota = 10
#   list_of_vdcs = ["my-vdc"]

#   vapp_lease {
#     maximum_runtime_lease_in_sec          = 3600 # 1 hour
#     power_off_on_runtime_lease_expiration = true
#     maximum_storage_lease_in_sec          = 0 # never expires
#     delete_on_storage_lease_expiration    = false
#   }
#   vapp_template_lease {
#     maximum_storage_lease_in_sec       = 604800 # 1 week
#     delete_on_storage_lease_expiration = true
#   }
#   account_lockout {
#     enabled                       = true
#     invalid_logins_before_lockout = 10
#     lockout_interval_minutes      = 60
#   }
# }

data "vcd_org" "my-org" {
  name = var.orgname
}

output "full_name" {
  value = data.vcd_org.my-org.full_name
}