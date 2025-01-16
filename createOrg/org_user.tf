resource "vcd_org_user" "org-admin" {
  org = data.vcd_org.org1.name

  name        = "${var.org_name}-admin"
  description = "${var.org_name} administrator user"
  role        = "Organization Administrator"
  password    = var.org_admin_password
}
