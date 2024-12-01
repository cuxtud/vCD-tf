data "vcd_provider_vdc" "nsxt-pvdc" {
  name = "my-nsxt-pvdc"
}

data "vcd_nsxt_edge_cluster" "ec" {
  provider_vdc_id = data.vcd_provider_vdc.nsxt-pvdc.id
  name            = "edge-cluster-1"
}

resource "vcd_org_vdc" "nsxt-vdc" {
  name = "NSXT-VDC"
  org  = "main-org"

  allocation_model  = "ReservationPool"
  network_pool_name = "NSX-T Overlay 1"
  provider_vdc_name = "nsxTPvdc1"
  edge_cluster_id   = data.vcd_nsxt_edge_cluster.ec.id

  compute_capacity {
    cpu {
      allocated = "1024"
      limit     = "1024"
    }

    memory {
      allocated = "1024"
      limit     = "1024"
    }
  }

  storage_profile {
    name    = "*"
    enabled = true
    limit   = 10240
    default = true
  }

  enabled                  = true
  enable_thin_provisioning = true
  enable_fast_provisioning = true
  delete_force             = true
  delete_recursive         = true
}