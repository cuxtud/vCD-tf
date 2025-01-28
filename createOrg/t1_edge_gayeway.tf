data "vcd_external_network_v2" "external_network" {
  name = var.provider_gateway_name
}

data "vcd_org" "org1" {
  name = var.org_name 

  depends_on = [ vcd_org.my-org ]
}

data "vcd_org_vdc" "vdc" {
  name = var.vdc_name
  org  = var.org_name

  depends_on = [ vcd_org_vdc.my_vdc ]
}

resource "vcd_nsxt_edgegateway" "edge_gateway" {
  org                 = var.org_name
  owner_id            = data.vcd_org_vdc.vdc.id
  name                = "${var.org_name}-edge-gateway"
  description         = "Edge Gateway created via Terraform"
  external_network_id = data.vcd_external_network_v2.external_network.id
  depends_on = [ vcd_ip_space.space1 ]
}

# variable "t0_gateway_name" {
#   default = "Provider-T0"
# }

data "vcd_ip_space" "uplink_ip" {
  name = "IPSpace_public"
}

resource "vcd_ip_space_ip_allocation" "public_floating_ip" {
  org_id      = data.vcd_org.org1.id          
  ip_space_id = data.vcd_ip_space.uplink_ip.id 
  type        = "FLOATING_IP"                  

  depends_on = [vcd_nsxt_edgegateway.edge_gateway] 
}

output "public_floating_ip_address" {
  value = vcd_ip_space_ip_allocation.public_floating_ip.ip_address
  description = "The public floating IP address allocated for org."
}

resource "vcd_nsxt_nat_rule" "snat" {
  org = var.org_name

  edge_gateway_id = vcd_nsxt_edgegateway.edge_gateway.id

  name        = "${var.org_name} IPSpace-public-uplink default"
  rule_type   = "SNAT"
  description = "${var.org_name} IPSpace-public-uplink default"

  external_address = vcd_ip_space_ip_allocation.public_floating_ip.ip_address
  internal_address         = "10.0.0.0/24"
  snat_destination_address = "8.8.8.8"
  logging                  = false

  depends_on = [ vcd_ip_space_ip_allocation.public_floating_ip ]
}

resource "vcd_ip_space_ip_allocation" "default_ip_prefix" {
  org_id      = vcd_org.my-org.id
  ip_space_id = vcd_ip_space.space1.id
  type        = "IP_PREFIX"
  value       = "10.0.0.0/24"  
}

resource "vcd_ip_space_ip_allocation" "172_16_0_0_24" {
  org_id      = vcd_org.my-org.id
  ip_space_id = vcd_ip_space.space1.id
  type        = "IP_PREFIX"
  value       = "172.16.0.0/24"  
}

resource "vcd_ip_space_ip_allocation" "192_168_0_0_24" {
  org_id      = vcd_org.my-org.id
  ip_space_id = vcd_ip_space.space1.id
  type        = "IP_PREFIX"
  value       = "192.168.0.0/24"  
}

resource "vcd_ip_space_ip_allocation" "192_168_50_0_25" {
  org_id      = vcd_org.my-org.id
  ip_space_id = vcd_ip_space.space1.id
  type        = "IP_PREFIX"
  value       = "192.168.50.0/25"  
}

resource "vcd_ip_space_ip_allocation" "172_17_0_0_25" {
  org_id      = vcd_org.my-org.id
  ip_space_id = vcd_ip_space.space1.id
  type        = "IP_PREFIX"
  value       = "172.17.0.0/25"  
}

resource "vcd_ip_space_ip_allocation" "10_1_0_0_25" {
  org_id      = vcd_org.my-org.id
  ip_space_id = vcd_ip_space.space1.id
  type        = "IP_PREFIX"
  value       = "10.1.0.0/25"  
}

resource "vcd_ip_space_ip_allocation" "192_168_100_0_26" {
  org_id      = vcd_org.my-org.id
  ip_space_id = vcd_ip_space.space1.id
  type        = "IP_PREFIX"
  value       = "192.168.100.0/26"  
}

resource "vcd_ip_space_ip_allocation" "172_18_0_0_26" {
  org_id      = vcd_org.my-org.id
  ip_space_id = vcd_ip_space.space1.id
  type        = "IP_PREFIX"
  value       = "172.18.0.0/26"  
}

resource "vcd_ip_space_ip_allocation" "10_2_0_0_26" {
  org_id      = vcd_org.my-org.id
  ip_space_id = vcd_ip_space.space1.id
  type        = "IP_PREFIX"
  value       = "10.2.0.0/26"  
}

#Add default router network to the vcd
resource "vcd_network_routed_v2" "default-routed-network" {
  org         = data.vcd_org.org1.name
  name        = "Default-Network"
  description = "Routed Org VDC network backed by NSX-T"

  edge_gateway_id = vcd_nsxt_edgegateway.edge_gateway.id

  gateway            = "10.0.0.1"
  prefix_length      = 24

  depends_on = [ vcd_ip_space_ip_allocation.default_ip_prefix ]
}