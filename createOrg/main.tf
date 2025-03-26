resource "vcd_org" "my-org" {
  name             = var.org_name
  full_name        = var.org_full_name
  description      = var.org_description
  is_enabled       = true
  delete_recursive = true
  delete_force     = true
  deployed_vm_quota = 10
  stored_vm_quota = 10

  vapp_lease {
    maximum_runtime_lease_in_sec          = 3600 
    power_off_on_runtime_lease_expiration = true
    maximum_storage_lease_in_sec          = 0 
    delete_on_storage_lease_expiration    = false
  }
  vapp_template_lease {
    maximum_storage_lease_in_sec       = 604800 
    delete_on_storage_lease_expiration = true
  }
  account_lockout {
    enabled                       = true
    invalid_logins_before_lockout = 10
    lockout_interval_minutes      = 60
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "vcd_org_vdc" "my_vdc" {
  name = var.vdc_name
  org  = vcd_org.my-org.name
  
  depends_on = [vcd_org.my-org]
  
  allocation_model = "AllocationVApp"
  network_pool_name = var.network_pool_name
  provider_vdc_name = var.provider_vdc_name
  delete_force             = true
  delete_recursive         = true

  compute_capacity {
    cpu {
      allocated = 0
      limit     = 0
    }

    memory {
      allocated = 0
      limit     = 0
    }
  }
  cpu_speed = 2100
  memory_guaranteed = 0
  cpu_guaranteed = 0
  storage_profile {
    name    = var.storage_profile_name
    enabled = true
    limit   = 10240
    default = true
  }

  network_quota = 50
  vm_quota      = 100
  enabled       = true

  lifecycle {
    create_before_destroy = true 
  }
}
