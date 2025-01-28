resource "vcd_ip_space" "space1" {
  name        = "IPSpace-Private_${var.org_name}"
  description = "Private IP Space created for org ${var.org_name}"
  type        = "PRIVATE"
  org_id      = vcd_org.my-org.id

  internal_scope = ["10.0.0.0/8", "192.168.0.0/16", "172.16.0.0/12"]
  external_scope = "0.0.0.0/0"
  route_advertisement_enabled = false
  default_firewall_rule_creation_enabled = true
  default_snat_rule_creation_enabled     = true

  # /24 prefixes
  ip_prefix {
    default_quota = -1 
    prefix {
      first_ip      = "172.16.0.0"
      prefix_length = 24
      prefix_count  = 250
    }
    prefix {
      first_ip      = "10.0.0.0"
      prefix_length = 24
      prefix_count  = 250
    }
    prefix {
      first_ip      = "192.168.0.0"
      prefix_length = 24
      prefix_count  = 50
    }
  }

  # /25 prefixes
  ip_prefix {
    default_quota = -1 
    prefix {
      first_ip      = "192.168.50.0"
      prefix_length = 25
      prefix_count  = 50
    }
    prefix {
      first_ip      = "172.17.0.0"
      prefix_length = 25
      prefix_count  = 250
    }
    prefix {
      first_ip      = "10.1.0.0"
      prefix_length = 25
      prefix_count  = 250
    }
  }

  # /26 prefixes
  ip_prefix {
    default_quota = -1 
    prefix {
      first_ip      = "192.168.100.0"
      prefix_length = 26
      prefix_count  = 50
    }
    prefix {
      first_ip      = "172.18.0.0"
      prefix_length = 26
      prefix_count  = 250
    }
    prefix {
      first_ip      = "10.2.0.0"
      prefix_length = 26
      prefix_count  = 250
    }
  }
} 


