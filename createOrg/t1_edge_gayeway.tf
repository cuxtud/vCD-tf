data "vcd_external_network_v2" "external_network" {
  name = var.t0_gateway_name
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
  name                = "my-edge-gateway"
  description         = "Edge Gateway created via Terraform"
  external_network_id = data.vcd_external_network_v2.external_network.id
  depends_on = [ vcd_ip_space.space1 ]
}

variable "t0_gateway_name" {
  default = "Provider-T0"
}

# data "vcd_ip_space_uplink" "uplink_ip" {
#   name                = "IPSpace-public" # Replace with your uplink name
#   external_network_id = data.vcd_external_network_v2.external_network.id
# }

data "vcd_ip_space" "uplink_ip" {
  name = "IPSpace_public"
  # org_id = data.vcd_org.org_info.id
}

resource "vcd_ip_space_ip_allocation" "public_floating_ip" {
  org_id      = data.vcd_org.org1.id          // Replace with your organization ID
  ip_space_id = data.vcd_ip_space.uplink_ip.id // Use the uplink IP space ID
  type        = "FLOATING_IP"                  // Specify the type of IP allocation

  depends_on = [vcd_nsxt_edgegateway.edge_gateway] // Ensure the edge gateway is created first
}

output "public_floating_ip_address" {
  value = vcd_ip_space_ip_allocation.public_floating_ip.ip_address
  description = "The public floating IP address allocated."
}


#Add snat rule to the edge gateway
resource "vcd_nsxt_nat_rule" "snat" {
  org = var.org_name

  edge_gateway_id = vcd_nsxt_edgegateway.edge_gateway.id

  name        = "IPSpace-public-uplink default"
  rule_type   = "SNAT"
  description = "IPSpace-public-uplink default"

  external_address = vcd_ip_space_ip_allocation.public_floating_ip.ip_address
  internal_address         = "10.0.0.0/24"
  snat_destination_address = "8.8.8.8"
  logging                  = false

  depends_on = [ vcd_ip_space_ip_allocation.public_floating_ip ]
}

