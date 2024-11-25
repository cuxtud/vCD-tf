resource "vcd_org" "my-org" {
  name             = "anish-org"
  full_name        = "Anish organization"
  description      = "Anish Test org"
  is_enabled       = true
  delete_recursive = true
  delete_force     = true
  deployed_vm_quota = 10
  stored_vm_quota = 10
  #list_of_vdcs = ["my-vdc"]

  vapp_lease {
    maximum_runtime_lease_in_sec          = 3600 # 1 hour
    power_off_on_runtime_lease_expiration = true
    maximum_storage_lease_in_sec          = 0 # never expires
    delete_on_storage_lease_expiration    = false
  }
  vapp_template_lease {
    maximum_storage_lease_in_sec       = 604800 # 1 week
    delete_on_storage_lease_expiration = true
  }
  account_lockout {
    enabled                       = true
    invalid_logins_before_lockout = 10
    lockout_interval_minutes      = 60
  }
}


resource "vcd_org_vdc" "my_vdc" {
  name = "anish-vdc"
  org  = vcd_org.my-org.name

  allocation_model = "AllocationVApp"
  network_pool_name = var.network_pool_name
  provider_vdc_name = var.provider_vdc_name

  compute_capacity {
    cpu {
      allocated = 10240
      limit     = 10240
    }

    memory {
      allocated = 10240
      limit     = 10240
    }
  }

  storage_profile {
    name    = var.storage_profile_name
    enabled = true
    limit   = 10240
    default = true
  }

  network_quota = 10
  vm_quota      = 10
  enabled       = true
}
# data "vcd_org" "my-org" {
#   name = vcd_org.my-org.name
# }

# output "full_name" {
#   value = data.vcd_org.my-org.full_name
# }